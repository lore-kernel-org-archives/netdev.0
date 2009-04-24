From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and security_socket_post_recv_datagram().
Date: Fri, 24 Apr 2009 14:26:24 +0900
Message-ID: <200904240526.n3O5QO01039109@www262.sakura.ne.jp>
References: <20090422061006.GB27688@bx9.net> <20090421.233403.83067664.davem@davemloft.net> <200904240207.n3O27Sb0096107@www262.sakura.ne.jp> <20090423.213542.03667490.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org, greg@blekko.com
To: davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OK. I understood that security_socket_post_recv_datagram() must not return
-EAGAIN if a process calls recvmsg() after poll() said "ready".
That will be also true for security_socket_recvmsg().


Is it OK for security_socket_recvmsg()/security_socket_accept() to return
an error other than -EAGAIN?
(In other words, security_socket_recvmsg()/security_socket_accept() errors are
one of "hard" errors?)
