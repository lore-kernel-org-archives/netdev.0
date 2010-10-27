From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pktgen: Remove a dangerous debug print.
Date: Wed, 27 Oct 2010 21:41:39 +0200
Message-ID: <1288208499.2658.19.camel@edumazet-laptop>
References: <1288206788-21063-1-git-send-email-nelhage@ksplice.com>
	 <20101027.122143.02260950.davem@davemloft.net>
	 <20101027192808.GP16803@ksplice.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, robert.olsson@its.uu.se,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	eugene@redhat.com
To: Nelson Elhage <nelhage@ksplice.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101027192808.GP16803@ksplice.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 27 octobre 2010 =C3=A0 15:28 -0400, Nelson Elhage a =C3=A9c=
rit :
> How would you feel about limiting the debug print to at most, say, 51=
2 or 1024
> bytes? Even if it's only accessible to root by default, I don't a use=
rspace
> program should be able to accidentally corrupt the kernel stack by wr=
iting too
> many bytes to a file in /proc.

Arent /proc writes limited to PAGE_SIZE anyway ?

On x86 at least, you cannot corrupt kernel stack, since its bigger than
PAGE_SIZE.

I agree pktgen code is a bit ugly and needs a cleanup, but who
cares ? :)
