From: Greg Lindahl <greg@blekko.com>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and
	security_socket_post_recv_datagram().
Date: Tue, 21 Apr 2009 23:41:59 -0700
Message-ID: <20090422064159.GA4221@bx9.net>
References: <20090422015228.GA13312@bx9.net> <20090421.212342.235921625.davem@davemloft.net> <20090422061006.GB27688@bx9.net> <20090421.233403.83067664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: penguin-kernel@i-love.sakura.ne.jp, paul.moore@hp.com,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090421.233403.83067664.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 21, 2009 at 11:34:03PM -0700, David Miller wrote:

> People use poll() to avoid -EAGAIN and blocking, they expect the bits
> to tell them what fd's they can work on to do real work.

My point is that EAGAIN happens already. So you can't claim that
returning it in accept() breaks the interface, when it's common enough
that today's user-level network code already handles it.

I have no opinion about TOMOYO. There are many reasons other than
EAGAIN from accept() to complain about.

-- greg

