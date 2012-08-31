From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] tcp: Wrong timeout for SYN segments
Date: Fri, 31 Aug 2012 15:47:01 -0400 (EDT)
Message-ID: <20120831.154701.958704113365912999.davem@davemloft.net>
References: <20120831124831.GA23279@linlab.net>
	<1346419550.2591.12.camel@edumazet-glaptop>
	<20120831.154234.735439593093335863.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex@linlab.net, hkjerry.chu@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120831.154234.735439593093335863.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Fri, 31 Aug 2012 15:42:34 -0400 (EDT)

> Applied with some minor comment formatting and wording adjustments.

BTW, please keep in mind that when you modify the value
of TCP_SYN_RETRIES, you are having an influence upon DCCP
as well.

TCP is not the only protocol which uses this value.
