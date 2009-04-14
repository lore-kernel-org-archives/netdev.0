From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: fix big endian MAC address collection failure
Date: Mon, 13 Apr 2009 18:40:35 -0700 (PDT)
Message-ID: <20090413.184035.137905532.davem@davemloft.net>
References: <1239661059.9237.4.camel@HP1>
	<1239661934.3278.113.camel@mulgrave.int.hansenpartnership.com>
	<20090414012548.GB11615@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: James.Bottomley@HansenPartnership.com, mchan@broadcom.com,
	netdev@vger.kernel.org, linux-parisc@vger.kernel.org
To: mcarlson@broadcom.com
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20090414012548.GB11615@xw6200.broadcom.net>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 13 Apr 2009 18:25:48 -0700

> Michael noticed that your NVRAM signature is byteswapped in NVRAM. (!)
> That also explains why the driver is trying to obtain the MAC address
> through NVRAM, rather than getting it from shared memory.  The device's
> bootcode is not working correctly.

If this problem is pervasive, which it seems it is since we
have at least two people hitting this problem, we'll need
to find a way to handle it without saying "update your
BIOS or system firmware"
