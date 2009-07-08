From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [RFC] Potential bug in defining 'irq field' of 'ifmap
 structure'
Date: Tue, 07 Jul 2009 18:32:55 -0700 (PDT)
Message-ID: <20090707.183255.193727664.davem@davemloft.net>
References: <CD8CC2B65FEE304DA95744A5472698F202952C3124@dlee06.ent.ti.com>
	<20090706.172501.136390568.davem@davemloft.net>
	<FCCFB4CDC6E5564B9182F639FC35608702F55E9549@dbde02.ent.ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: m-sonasath@ti.com, netdev@vger.kernel.org,
	linux-omap@vger.kernel.org
To: vikram.pandita@ti.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <FCCFB4CDC6E5564B9182F639FC35608702F55E9549@dbde02.ent.ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Pandita, Vikram" <vikram.pandita@ti.com>
Date: Wed, 8 Jul 2009 02:27:51 +0530

> On Zoom2 TI OMAP3 based board, the IRQ we are requesting is
> value=381 and hence the problem reported.

The IRQ reported by this user call is only reliable for
ISA devices.

Or, ARM platforms could opt to use a virtual IRQ scheme like
PowerPC and Sparc use, which keeps all device IRQs under
256.
