From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/6] vxlan: cleanup and IPv6 link-local
 support
Date: Tue, 20 Jun 2017 13:37:27 -0400 (EDT)
Message-ID: <20170620.133727.1870813949229996297.davem@davemloft.net>
References: <cover.1497825555.git.mschiffer@universe-factory.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, hannes@stressinduktion.org, pshelar@ovn.org,
        aduyck@mirantis.com, roopa@cumulusnetworks.com,
        netdev@vger.kernel.org, dev@openvswitch.org,
        linux-kernel@vger.kernel.org
To: mschiffer@universe-factory.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1497825555.git.mschiffer@universe-factory.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthias Schiffer <mschiffer@universe-factory.net>
Date: Mon, 19 Jun 2017 10:03:54 +0200

> Running VXLANs over IPv6 link-local addresses allows to use them as a
> drop-in replacement for VLANs, avoiding to allocate additional outer IP
> addresses to run the VXLAN over.
> 
> Since v1, I have added a lot more consistency checks to the address
> configuration, making sure address families and scopes match. To simplify
> the implementation, I also did some general refactoring of the
> configuration handling in the new first patch of the series.
> 
> The second patch is more cleanup; is slightly touches OVS code, so that
> list is in CC this time, too.
> 
> As in v1, the last two patches actually make VXLAN over IPv6 link-local
> work, and allow multiple VXLANs with the same VNI and port, as long as
> link-local addresses on different interfaces are used. As suggested, I now
> store in the flags field if the VXLAN uses link-local addresses or not.
> 
> v3 removes log messages as suggested by Roopa Prabhu (as it is very unusual
> for errors in netlink requests to be printed to the kernel log.) The commit
> message of patch 5 has been extended to add a note about IPv4.

Series applied, thanks Matthias.
