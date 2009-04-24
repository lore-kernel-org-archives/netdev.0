From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and security_socket_post_recv_datagram().
Date: Fri, 24 Apr 2009 11:07:28 +0900
Message-ID: <200904240207.n3O27Sb0096107@www262.sakura.ne.jp>
References: <20090422015228.GA13312@bx9.net> <20090421.212342.235921625.davem@davemloft.net> <20090422061006.GB27688@bx9.net> <20090421.233403.83067664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org, greg@blekko.com
To: davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090421.233403.83067664.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> People use poll() to avoid -EAGAIN and blocking, they expect the bits
> to tell them what fd's they can work on to do real work.

I found that "man 2 select" says

  Under Linux, select() may report a socket file descriptor as "ready for
  reading", while nevertheless a subsequent read blocks. This could for example
  happen when data has arrived but upon examination has wrong checksum and is
  discarded. There may be other circumstances in which a file descriptor is
  spuriously reported as ready. Thus it may be safer to use O_NONBLOCK on
  sockets that should not block.

  Linux 2.6.16                   2006-03-11                      SELECT(2)

People cannot use "poll()" to avoid blocking.
Applications had better not to completely depend on what poll() says.

> The current proposal is not acceptable.
You don't like TOMOYO's concept. I see.
But I don't see the reason you can't accept this proposal.
What does this proposal break? Please explain me.
