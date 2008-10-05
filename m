From: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Subject: Re: 2.6.27-rc8-git7: Reported regressions from 2.6.26
Date: Sun, 5 Oct 2008 11:14:26 +0400
Message-ID: <20081005071421.GA17685@2ka.mipt.ru>
References: <0pOgGB.A.uLG.E475IB@wind>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <0pOgGB.A.uLG.E475IB@wind>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi.

On Sat, Oct 04, 2008 at 07:28:42PM +0200, Rafael J. Wysocki (rjw-KKrjLPT3xs0@public.gmane.org) wrote:
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11308
> Subject		: tbench regression on each kernel release from 2.6.22 -&gt; 2.6.28
> Submitter	: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> Date		: 2008-08-11 18:36 (55 days old)
> References	: http://marc.info/?l=linux-kernel&m=121847986119495&w=4
> 		  http://marc.info/?l=linux-kernel&m=122125737421332&w=4

Just for the reference, this one regresses from the 2.6.23. Particular
2.6.26-27 part can be partially fixed by disabling TSO/GSO, since tbench
workload issues quite small packets, and system has no time to
incorporate them into particulary big TSO/GSO frame to get advantage of
this technology. The most noticeble perfromance drop was between 23 and
24 kernels. I work on this issue.
 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11207
> Subject		: VolanoMark regression with 2.6.27-rc1
> Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> Date		: 2008-07-31 3:20 (66 days old)
> References	: http://marc.info/?l=linux-kernel&m=121747464114335&w=4
> Handled-By	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> 		  Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
> 		  Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> 		  Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

This one is different, but any other benchmark related to network over
loopback (and in some case over other media) performance degradation
should be very likely handled by the above case.

-- 
	Evgeniy Polyakov
