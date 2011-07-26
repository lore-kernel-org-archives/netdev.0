From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Tue, 26 Jul 2011 20:21:23 +0900
Message-ID: <201107262021.FCC34304.HMOOFQJVSFLFOt@I-love.SAKURA.ne.jp>
References: <20110725222010.0b284042@kryten>
	<201107252215.GBG95887.OQVMFOOJLSFFHt@I-love.SAKURA.ne.jp>
	<4E2D8F4D.2000009@schaufler-ca.com>
	<201107260143.CGH18263.FOOSVMOQFJFLHt@I-love.SAKURA.ne.jp>
	<20110726195557.5abcf96d@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: casey@schaufler-ca.com, mjt@tls.msk.ru, davem@davemloft.net,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: anton@samba.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20110726195557.5abcf96d@kryten>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anton Blanchard wrote:
> Not sure what happened to your email but the gains are evident at
> just 2 packets.

I know your benchmark result, but that result is based on calling
security_socket_sendmsg() only once.

What we worry is that overhead by security_socket_sendmsg() kills the
performance gain for batched case.

> I can help with testing - the commit included a microbenchmark for
> the purposes of analysing its performance.

Yes please. The patch in msg11510.html would want some more discussion, but
the patch in msg11504.html is ready to benchmark on your environment.

Does SELinux want to receive nosec flag at selinux_socket_sendmsg() because
calling security_socket_sendmsg() more than once is meaningless for SELinux?
