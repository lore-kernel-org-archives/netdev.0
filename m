From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB originated
 TCP streams
Date: Mon, 6 Feb 2012 17:22:56 +0200
Message-ID: <4F2FF050.7040400@mellanox.com>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com>   <alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com>   <alpine.LRH.2.00.1202022352560.30300@ogerlitz.voltaire.com>   <1828884A29C6694DAF28B7E6B8A823733349A5D2@ORSMSX101.amr.corp.intel.com>  <1328259640.2480.43.camel@edumazet-laptop>  <1828884A29C6694DAF28B7E6B8A823733349A6C9@ORSMSX101.amr.corp.intel.com>  <4F2FEC36.6090800@mellanox.com> <1328541706.2220.50.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1328541706.2220.50.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2/6/2012 5:21 PM, Eric Dumazet wrote:
> Sure, I suggest two patches then. One from me (the one I sent 
> earlier), introducing the core infrastructure, and one from you adding 
> the "dev->gro_mac_header_len = IPOIB_ENCAP_LEN;" in 
> drivers/infiniband/ulp/ipoib/ipoib_main.c If you agree, I'll resend my 
> part with official submission, and you'll send your patch after ? 

sure, sounds excellent, lets do that

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
