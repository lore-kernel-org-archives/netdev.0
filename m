From: Karsten Desler <kdesler@soohrt.org>
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: Mon, 6 Dec 2004 23:41:07 +0100
Message-ID: <20041206224107.GA8529@soohrt.org>
References: <20041206205305.GA11970@soohrt.org> <20041206134849.498bfc93.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261685AbULFWlQ@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041206134849.498bfc93.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David S. Miller wrote:
> It's spending nearly half of it's time in iptables.
> Try to consolidate your rules if possible.  This is the
> part of netfilter that really doesn't scale well at all.
> 

Removing the iptables rules helps reducing the load a little, but the
majority of time is still spent somewhere else.

50kpps rx and 43kpps tx.
procs -----------memory---------- ---swap-- -----io---- --system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id wa
 0  0      0 1802956 101032 104464    0    0     0    18   74    26  0 21 79  0
 0  0      0 1802956 101032 104464    0    0     0    61 8810    28  0 25 75  0
 0  0      0 1802956 101032 104464    0    0     0   233 8867    17  0 24 76  0
 0  0      0 1802892 101032 104464    0    0     0     0 8865    16  0 21 79  0
 0  0      0 1802892 101032 104464    0    0     0     0 8772     8  0 18 82  0 <- iptables -F
 0  0      0 1802892 101032 104464    0    0     0    36 8863    18  0 19 81  0
 0  0      0 1802892 101032 104464    0    0     0    80 8700    18  0 18 82  0
 0  0      0 1802956 101032 104464    0    0     0     0 8779     7  0 17 83  0
 0  0      0 1802948 101032 104464    0    0     0   223 8716   278  4 19 76  0

- Karsten
