From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: fix missing register reset on error path in
 sky2_test_msi()
Date: Sun, 01 Apr 2012 16:11:11 -0400 (EDT)
Message-ID: <20120401.161111.373860957994363057.davem@davemloft.net>
References: <20120330173616.GC2703@Neptun>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: LinoSanfilippo@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120330173616.GC2703@Neptun>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Date: Fri, 30 Mar 2012 19:36:16 +0200

> In sky2_test_msi() the temporarily set SW IRQ in B0 register is not reset in case
> that request_irq() fails.
> With this patch we only set the interrupt mask if request_irq() was successful.
> 
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Stephen, ping?
