From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 1/3] Security: Add disablenetwork interface. (v4)
Date: Wed, 30 Dec 2009 11:09:35 +0100
Message-ID: <20091230100935.GA32700@atrey.karlin.mff.cuni.cz>
References: <20091227075335.GA11737@elf.ucw.cz> <20091229012523.GB14362@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-2?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091229012523.GB14362@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Pavel Machek wrote:
> >>index 26a6b73..b48f021 100644
> >>--- a/kernel/sys.c
> >>+++ b/kernel/sys.c
> >>@@ -35,6 +35,7 @@
> >>  #include <linux/cpu.h>
> >>  #include <linux/ptrace.h>
> >>  #include <linux/fs_struct.h>
> >>+#include <linux/prctl_network.h>
> >>  
> >>  #include <linux/compat.h>
> >>  #include <linux/syscalls.h>
> >
> >Something seems to be wrong with whitespace here. Damaged patch?
> 
> Nope; kernel/sys.c has a newline there:
> 
>   http://repo.or.cz/w/linux-2.6.git/blob/HEAD:/kernel/sys.c#l36
> 
> Shall I remove it?

notice two spaces before include. something was definitely wrong there.

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
