From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC: 2.6 patch] remove drivers/net/eepro100.c
Date: Fri, 18 Nov 2005 01:08:02 -0800 (PST)
Message-ID: <20051118.010802.67654592.davem@davemloft.net>
References: <20051118033302.GO11494@stusta.de>
	<20051118090158.GA11621@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, saw@saw.sw.com.sg, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030596AbVKRJIQ@vger.kernel.org>
To: rmk+lkml@arm.linux.org.uk
In-Reply-To: <20051118090158.GA11621@flint.arm.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Russell King <rmk+lkml@arm.linux.org.uk>
Date: Fri, 18 Nov 2005 09:01:59 +0000

> On Fri, Nov 18, 2005 at 04:33:02AM +0100, Adrian Bunk wrote:
> > This patch removes the obsolete drivers/net/eepro100.c driver.
> > 
> > Is there any reason why it should be kept?
> 
> Tt's the only driver which works correctly on ARM CPUs.  e100 is
> basically buggy.  This has been discussed here on lkml and more
> recently on linux-netdev.  If anyone has any further questions
> please read the archives of those two lists.

Yes, sadly this is still true and therefore the eepro100 driver
needs to stick around.
