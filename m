From: Samir Bellabes <sam@synack.fr>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and security_socket_post_recv_datagram().
Date: Thu, 23 Apr 2009 16:47:22 +0200
Message-ID: <m2eivjtojp.fsf@ssh.synack.fr>
References: <200904220502.n3M52GQj001957@www262.sakura.ne.jp>
	<20090421.220735.118831531.davem@davemloft.net>
	<200904220538.n3M5c4QI010548@www262.sakura.ne.jp>
	<20090421.225202.218457438.davem@davemloft.net>
	<200904232300.IIB39542.SHJFLOtFVQFOMO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, paul.moore@hp.com,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200904232300.IIB39542.SHJFLOtFVQFOMO@I-love.SAKURA.ne.jp>
	(Tetsuo Handa's message of "Thu, 23 Apr 2009 23:00:09 +0900")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:

> There could be some programs which get confused by accept()/recvmsg() returning
> an error when poll() said "connections are ready" or "datagrams are ready".
> If we find such programs, we can tell TOMOYO to disable filtering for such
> programs.

Hello Tetsuo,

this will introduce a way to bypass the security system (?)

If TOMOYO won't filter such programs, people may add this "poll()"
feature to their code, in order to escape the security system.

I think it's strange for a security system to allow some programs
because of specific code issue, and not because of security reasons.

sam
