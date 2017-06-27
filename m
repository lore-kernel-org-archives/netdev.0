From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: fix incorrect nlattr access in MTU
 check
Date: Tue, 27 Jun 2017 14:40:52 -0400 (EDT)
Message-ID: <20170627.144052.2228259665374094222.davem@davemloft.net>
References: <a6097db8a2ce4a13c108651c58a345ccff3505b0.1498565985.git.mschiffer@universe-factory.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, roopa@cumulusnetworks.com, pshelar@ovn.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mschiffer@universe-factory.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a6097db8a2ce4a13c108651c58a345ccff3505b0.1498565985.git.mschiffer@universe-factory.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthias Schiffer <mschiffer@universe-factory.net>
Date: Tue, 27 Jun 2017 14:42:43 +0200

> The access to the wrong variable could lead to a NULL dereference and
> possibly other invalid memory reads in vxlan newlink/changelink requests
> with a IFLA_MTU attribute.
> 
> Fixes: a985343ba906 "vxlan: refactor verification and application of configuration"
> Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>

Applied, thanks.
