From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: xfrm: Can "struct netlbl_audit" be killed?
Date: Thu, 24 Apr 2014 23:29:08 +0900
Message-ID: <201404242329.FBF00065.OOQtHFMOLFSVFJ@I-love.SAKURA.ne.jp>
References: <201404242051.DBE04650.SOMVHtQFFOLFOJ@I-love.SAKURA.ne.jp>
	<29756536.Fj8RHVl2TT@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: casey@schaufler-ca.com, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: paul@paul-moore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:40738 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757400AbaDXO3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 10:29:19 -0400
In-Reply-To: <29756536.Fj8RHVl2TT@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Moore wrote:
> On Thursday, April 24, 2014 08:51:35 PM Tetsuo Handa wrote:
> > Hello, Casey and Paul.
> > 
> > At the ipsec-next tree,
> > 
> >   /* Audit Information */
> >   struct xfrm_audit {
> >   	u32     secid;
> >   	kuid_t  loginuid;
> >   	unsigned int sessionid;
> >   };
> > 
> > has just been killed
> > (
> > https://git.kernel.org/cgit/linux/kernel/git/klassert/ipsec-next.git/commit
> > /?id=f1370cc4a01e61007ab3020c761cef6b88ae3729 and
> > https://git.kernel.org/cgit/linux/kernel/git/klassert/ipsec-next.git/commit
> > /?id=2e71029e2c32ecd59a2e8f351517bfbbad42ac11 ) because these arguments are
> > always calculated from current thread's security context.
> 
> Before we go to far, is it always true for AF_KEY that "current" is set to the 
> sending process?  If the answer is no, I think we have a problem.

Speak of "struct xfrm_audit", I think the answer is yes, or commit ab5f5e8b
"[XFRM]: xfrm audit calls" is wrong.
