From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: change recvform to return same address length as
 getsockname on unnamed unix sockets
Date: Wed, 21 Apr 2010 22:26:02 -0700 (PDT)
Message-ID: <20100421.222602.211557559.davem@davemloft.net>
References: <v2x7447a0ac1004212029qd1866eaekc769fee5b13ac09d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ppergame@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <v2x7447a0ac1004212029qd1866eaekc769fee5b13ac09d@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Pergamenshchik <ppergame@gmail.com>
Date: Wed, 21 Apr 2010 20:29:25 -0700

> unix_*_recvmsg() returns zero-length sockaddr if the sender is an
> unnamed AF_UNIX socket. Change it to return a two-byte sockaddr with
> just the address family, to be consistent with unix_getname().
> 
> Signed-off-by: Pavel Pergamenshchik <ppergame@gmail.com>

Since we've behaved this way for at least 10 years, the existing
behavior is the user visible ABI and the risk of breaking things by
making the change is too great.

I'm not applying this, sorry.
