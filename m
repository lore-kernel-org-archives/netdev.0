From: Pavel Machek <pavel@ucw.cz>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Sun, 27 Dec 2009 09:38:57 +0100
Message-ID: <20091227083857.GC11737@elf.ucw.cz>
References: <20091227010441.GA12077@heat>
 <200912271736.GDB17180.OFJHOOQStMFLVF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: michael@laptop.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	andi@firstfloor.org, david@lang.hm, socketcan@hartkopp.net,
	alan@lxorguk.ukuu.org.uk, herbert@gondor.apana.org.au,
	Valdis.Kletnieks@vt.edu, bdonlan@gmail.com, zbr@ioremap.net,
	cscott@cscott.net, jmorris@namei.org, ebiederm@xmission.com,
	bernie@codewiz.org, mrs@mythic-beasts.com, randy.dunlap@oracle.com,
	xiyou.wangcong@gmail.com, sam@synack.fr, casey@schaufler-ca.com,
	serue@us.ibm.com
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200912271736.GDB17180.OFJHOOQStMFLVF@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun 2009-12-27 17:36:48, Tetsuo Handa wrote:
> Michael Stone wrote:
> > Further suggestions?
> 
> I expect that the future figure of this "disablenetwork" functionality becomes
> "disablesyscall" functionality.
> 
> What about defining two types of masks, one is applied throughout the rest of
> the task_struct's lifetime (inheritable mask), the other is cleared when
> execve() succeeds (local mask)?
> 
> When an application is sure that "I know I don't need to call execve()" or
> "I know execve()d programs need not to call ...()" or "I want execve()d
> programs not to call ...()", the application sets inheritable mask.
> When an application is not sure about what syscalls the execve()d programs
> will call but is sure that "I know I don't need to call ...()", the application
> sets local mask.

Syscalls are very wrong granularity for security system. But easy to
implement, see seccomp.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
