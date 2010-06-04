From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [Patch] infiniband: check local reserved ports
Date: Fri, 04 Jun 2010 09:04:53 -0700
Message-ID: <ada1vcmpyvu.fsf@roland-alpha.cisco.com>
References: <20100603083106.6047.7657.sendpatchset@localhost.localdomain>
	<ada1vcoqde3.fsf@roland-alpha.cisco.com> <4C085C9A.30506@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Tetsuo Handa <penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4C085C9A.30506-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Cong Wang's message of "Fri, 04 Jun
	2010 09:53:30 +0800")
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 > > Should this inet_is_reserved_local_port() test apply to all the "port
 > > spaces" that this code is handling?  I honestly am ignorant of the
 > > intended semantics of the new local_reserved_ports stuff, hence my question.

 > Yes, but I only found this case, is there any else?

My question was more in the other direction: should this test apply to
all the "port spaces" handled here?  From looking at the code, it
appears the answer is yes -- it seems that putting a port in
local_reserved_ports reserves that port for IPv4 and IPv6, UDP, TCP,
SCTP, DCCP, everything, so we should probably reserve all RDMA CM ports too.
-- 
Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org> || For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
