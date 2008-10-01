From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v6 04/16] selinux: Better local/forward check in
 selinux_ip_postroute()
Date: Wed, 1 Oct 2008 11:43:12 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0810011141180.5277@tundra.namei.org>
References: <20080916124722.17132.38741.stgit@flek.lan> <20080916125613.17132.70639.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080916125613.17132.70639.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Sep 2008, Paul Moore wrote:

> It turns out that checking to see if skb->sk is NULL is not a very good
> indicator of a forwarded packet as some locally generated packets also have
> skb->sk set to NULL.  Fix this by not only checking the skb->sk field but also
> the IP[6]CB(skb)->flags field for the IP[6]SKB_FORWARDED flag.  While we are
> at it, we are calling selinux_parse_skb() much earlier than we really should
> resulting in potentially wasted cycles parsing packets for information we
> might no use; so shuffle the code around a bit to fix this.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Acked-by: James Morris <jmorris@namei.org>

(Wow, this code is getting complex... :-)


-- 
James Morris
<jmorris@namei.org>
