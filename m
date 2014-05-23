From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Fwd: [Bug 76781] New: unable to handle NULL in xfrm_input+0x173,
 fatal exception in interrupt
Date: Fri, 23 May 2014 11:15:51 +0200
Message-ID: <20140523091551.GI32371@secunet.com>
References: <bug-76781-65011@https.bugzilla.kernel.org/>
 <537F09EE.5000703@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <cate@cateee.net>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34762 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750958AbaEWJQH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2014 05:16:07 -0400
Content-Disposition: inline
In-Reply-To: <537F09EE.5000703@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 23, 2014 at 10:42:22AM +0200, Daniel Borkmann wrote:
> 
> -------- Original Message --------
> Subject: [Bug 76781] New: unable to handle NULL in xfrm_input+0x173, fatal exception in interrupt
> Date: Fri, 23 May 2014 07:07:40 +0000
> From: bugzilla-daemon@bugzilla.kernel.org
> To: dborkman@redhat.com
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=76781
> 
>             Bug ID: 76781
>            Summary: unable to handle NULL in xfrm_input+0x173, fatal
>                     exception in interrupt
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.15.0-rc6
>           Hardware: x86-64
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: shemminger@linux-foundation.org
>           Reporter: cate@cateee.net
>         Regression: No
> 
> See also the fatal oops in:
> 
> http://cateee.net/kernel/IMG_20140522_225238.jpg
> http://cateee.net/kernel/IMG_20140523_082629.jpg
> 
> It seems it happens "often": twice in last few hours I used the new kernels.
> (the first oops was with 3.15.0-rc5-00270-gfba69f0)
> 
> I had also usual debian unstable updates, and I just finished to instal aiccu
> (a sixxs program for dynamic ip6to4, so I'm not sure it is a recent bug or just
> I forced it to appear in very last HEAD.
> 

This might be fixed by these two commits:

commit edb666f07e ("xfrm6: Properly handle unsupported protocols")
commit 61622cc6f2 ("xfrm4: Properly handle unsupported protocols")
