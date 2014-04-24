From: Paul Moore <paul@paul-moore.com>
Subject: Re: xfrm: Can "struct netlbl_audit" be killed?
Date: Thu, 24 Apr 2014 10:40:37 -0400
Message-ID: <29136798.pGbRqWE1nJ@sifl>
References: <201404242051.DBE04650.SOMVHtQFFOLFOJ@I-love.SAKURA.ne.jp> <29756536.Fj8RHVl2TT@sifl> <201404242329.FBF00065.OOQtHFMOLFSVFJ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: casey@schaufler-ca.com, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201404242329.FBF00065.OOQtHFMOLFSVFJ@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, April 24, 2014 11:29:08 PM Tetsuo Handa wrote:
> Paul Moore wrote:
> > On Thursday, April 24, 2014 08:51:35 PM Tetsuo Handa wrote:
> > > Hello, Casey and Paul.
> > > 
> > > At the ipsec-next tree,
> > > 
> > >   /* Audit Information */
> > >   struct xfrm_audit {
> > >   
> > >   	u32     secid;
> > >   	kuid_t  loginuid;
> > >   	unsigned int sessionid;
> > >   
> > >   };
> > > 
> > > has just been killed
> > > (
> > > https://git.kernel.org/cgit/linux/kernel/git/klassert/ipsec-next.git/com
> > > mit
> > > /?id=f1370cc4a01e61007ab3020c761cef6b88ae3729 and
> > > https://git.kernel.org/cgit/linux/kernel/git/klassert/ipsec-next.git/com
> > > mit
> > > /?id=2e71029e2c32ecd59a2e8f351517bfbbad42ac11 ) because these arguments
> > > are
> > > always calculated from current thread's security context.
> > 
> > Before we go to far, is it always true for AF_KEY that "current" is set to
> > the sending process?  If the answer is no, I think we have a problem.
> 
> Speak of "struct xfrm_audit", I think the answer is yes, or commit ab5f5e8b
> "[XFRM]: xfrm audit calls" is wrong.

I'm not assuming that ab5f5e8b is correct.  It would be nice to know for sure 
that current is always equal to the sending process for AF_KEY, and that isn't 
something I'm certain is true off the top of my head.

-- 
paul moore
www.paul-moore.com

