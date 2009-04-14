From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: fix big endian MAC address collection failure
Date: Mon, 13 Apr 2009 19:51:59 -0700 (PDT)
Message-ID: <20090413.195159.56924183.davem@davemloft.net>
References: <20090414012548.GB11615@xw6200.broadcom.net>
	<20090413.184035.137905532.davem@davemloft.net>
	<20090414020015.GC11615@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: James.Bottomley@HansenPartnership.com, mchan@broadcom.com,
	netdev@vger.kernel.org, linux-parisc@vger.kernel.org
To: mcarlson@broadcom.com
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20090414020015.GC11615@xw6200.broadcom.net>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 13 Apr 2009 19:00:15 -0700

> I did run some tests this afternoon on a similar IA64 HP machine and
> they ran fine.

It can't be similar, James Bottomly is on HP PARISC (big endian) not
IA64 (which is little endian).

I'm still convinced this is a big-endian driver problem and it has
nothing to do with broken NVRAM or similar.
