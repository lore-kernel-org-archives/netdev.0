From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix tcp_fastopen unaligned access complaints on
 sparc
Date: Thu, 12 Jan 2017 16:47:31 -0500 (EST)
Message-ID: <20170112.164731.720625943370044951.davem@davemloft.net>
References: <131ec7b7-5b74-2545-8bf7-92812443a876@oracle.com>
        <20170112.161852.1469407145449781531.davem@davemloft.net>
        <1484256990.13165.6.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shannon.nelson@oracle.com, rob.gardner@oracle.com,
        netdev@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1484256990.13165.6.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 Jan 2017 13:36:30 -0800

> val should be an union, so that proper alignment is enforced by one
> member.

Sure, annotating the type so that it is aligned correctly makes
sense.
