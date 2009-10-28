From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fold network name hash (v2)
Date: Wed, 28 Oct 2009 02:28:56 -0700 (PDT)
Message-ID: <20091028.022856.178916261.davem@davemloft.net>
References: <20091027102251.244ee681@nehalam>
	<20091027150436.56e673cd@nehalam>
	<4AE7DF8E.3020607@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, opurdila@ixiacom.com,
	viro@zeniv.linux.org.uk
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757566AbZJ1J2e@vger.kernel.org>
In-Reply-To: <4AE7DF8E.3020607@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 28 Oct 2009 07:07:10 +0100

> You should therefore use hash_32(hash, NETDEV_HASHBITS),
> not hash_long() that maps to hash_64() on 64 bit arches, which is
> slower and certainly not any better with a 32bits input.

Agreed.
