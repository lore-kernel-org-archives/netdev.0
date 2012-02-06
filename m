From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB originated
 TCP streams
Date: Mon, 6 Feb 2012 17:05:26 +0200
Message-ID: <4F2FEC36.6090800@mellanox.com>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com>  <alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com>  <alpine.LRH.2.00.1202022352560.30300@ogerlitz.voltaire.com>  <1828884A29C6694DAF28B7E6B8A823733349A5D2@ORSMSX101.amr.corp.intel.com> <1328259640.2480.43.camel@edumazet-laptop> <1828884A29C6694DAF28B7E6B8A823733349A6C9@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A823733349A6C9-P5GAC/sN6hmkrb+BlOpmy7fspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2/3/2012 10:24 PM, Hefty, Sean wrote:
>> Hmm... a tcpdump would help to understand what is going on (for example if GRO kicks in)
>
> I should stop trying to apply patches so late.  I must have done something wrong with my quick test.  Re-applying the patch on 3.2, the ipoib UD performance looks okay to me with Eric's patch.  Sorry about the flub.
>

Sean, same here, with both 3.2 and 3.3-rc1 I see with tcpdump that no 
GRO aggregation is done in the receiving side, when applying the patch I 
sent (Eric's patch enhanced to change ipoib code such that it sets 
gro_mac_header_lento the ipoib header len), I can see GRO aggregation 
and the performance goes well up. So how do we go from here? Herbert, 
Roland, are you okay with the patch?

Eric, if this we're going on that patch, could you please add 
Reported-by: Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> to the change-log.

Or.

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
