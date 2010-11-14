From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: mitigate an integer underflow when comparing tcp
 timestamps
Date: Sun, 14 Nov 2010 11:55:36 -0800 (PST)
Message-ID: <20101114.115536.71112799.davem@davemloft.net>
References: <1289720156-30118-1-git-send-email-r0bertz@gentoo.org>
	<1289724745.2743.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: r0bertz@gentoo.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1289724745.2743.61.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 14 Nov 2010 09:52:25 +0100

> Really, if you have multiple clients behind a common NAT, you cannot use
> this code at all, since NAT doesnt usually change TCP timestamps.

NAT is %100 incompatible with TW recycling, full stop.

There is no maybe, or maybe not.

If you are behind NAT you must not turn this feature on, ever.
