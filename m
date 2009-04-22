From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and security_socket_post_recv_datagram().
Date: Wed, 22 Apr 2009 10:49:42 +0900
Message-ID: <200904220149.n3M1ngLa059958@www262.sakura.ne.jp>
References: <200904212152.FHH51019.MHOFVtOFSJFQOL@I-love.SAKURA.ne.jp> <20090421.060404.146628527.davem@davemloft.net> <200904220055.n3M0tQ6T048840@www262.sakura.ne.jp> <20090421.181411.26595688.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090421.181411.26595688.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> We had a similar situation with read()'s on UDP sockets.
> 
> When poll() says something, it has to stick.
To adhere what poll() said (i.e. "connections are ready" or "datagrams are
ready"), security_socket_accept() and security_socket_recvmsg() hooks must be
removed. Otherwise, LSM users cannot adhere what poll() said.

However, security_socket_accept() and security_socket_recvmsg() hooks remain
there. LSM users are already using semantics which may not adhere what poll()
said.
