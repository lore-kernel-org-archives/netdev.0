From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and
 security_socket_post_recv_datagram().
Date: Tue, 21 Apr 2009 22:52:02 -0700 (PDT)
Message-ID: <20090421.225202.218457438.davem@davemloft.net>
References: <200904220502.n3M52GQj001957@www262.sakura.ne.jp>
	<20090421.220735.118831531.davem@davemloft.net>
	<200904220538.n3M5c4QI010548@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: penguin-kernel@i-love.sakura.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200904220538.n3M5c4QI010548@www262.sakura.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Date: Wed, 22 Apr 2009 14:38:04 +0900

> If TOMOYO is allowed to make policy decisions based on the "task_struct" who
> picks up the connection/datagram, the only possible approach is to introduce
> security_socket_post_accept() and security_socket_post_recv_datagram().

Fine.

FWIW I do not agree with TOMOYO conceptually.  But if people are
generally going to let such a scheme into the kernel, I guess
I have to accept these socket layer hacks :-/
