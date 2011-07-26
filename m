From: Eric Paris <eparis@parisplace.org>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Tue, 26 Jul 2011 09:58:04 -0400
Message-ID: <CACLa4pvJ2+eTRf3SRzoXgiW8H+U=BDH-2DKVZ7pGRrPem=JYgg@mail.gmail.com>
References: <20110725222010.0b284042@kryten>
	<201107252215.GBG95887.OQVMFOOJLSFFHt@I-love.SAKURA.ne.jp>
	<4E2D8F4D.2000009@schaufler-ca.com>
	<201107260143.CGH18263.FOOSVMOQFJFLHt@I-love.SAKURA.ne.jp>
	<20110726195557.5abcf96d@kryten>
	<201107262021.FCC34304.HMOOFQJVSFLFOt@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: anton@samba.org, casey@schaufler-ca.com, mjt@tls.msk.ru,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201107262021.FCC34304.HMOOFQJVSFLFOt@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 26, 2011 at 7:21 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:

> Does SELinux want to receive nosec flag at selinux_socket_sendmsg() because
> calling security_socket_sendmsg() more than once is meaningless for SELinux?

SELinux would not mind having a flag such that we could expedite the
call on the 2nd or later.  Did we finally find the first place where
SELinux is going to be the faster LSM!  Never thought I'd see the day!

-Eric
