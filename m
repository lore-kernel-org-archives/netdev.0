From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 3/3] vxlan: allow multiple VXLANs with same VNI
 for IPv6 link-local addresses
Date: Wed, 15 Mar 2017 16:22:57 +0100
Message-ID: <20170315162257.127b27d6@griffin>
References: <cover.1489184335.git.mschiffer@universe-factory.net>
        <5c74248483272110d0ca249b80b943b0ceb0b610.1489184335.git.mschiffer@universe-factory.net>
        <20170314162815.7aae9e94@griffin>
        <1542ef1a-4bc2-d142-1910-0583c3c543a6@universe-factory.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hannes@stressinduktion.org, pshelar@ovn.org,
        aduyck@mirantis.com, roopa@cumulusnetworks.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matthias Schiffer <mschiffer@universe-factory.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1542ef1a-4bc2-d142-1910-0583c3c543a6@universe-factory.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 15 Mar 2017 15:29:29 +0100, Matthias Schiffer wrote:
> While ensuring that the destination address is link-local iff the source
> address is would also be an option, it didn't seem too useful as the
> destination address will be a multicast address anyways in "normal" VXLAN
> configurations. If we really want to check this, I guess the valid
> combinations are:
> 
> source link-local - destination link-local UC
> source link-local - destination link-local MC
> source global/... - destination global/... UC
> source global/... - destination any MC
> 
> Does this make sense?

It does.

Thanks!

 Jiri
