From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: avoid pci write posting after disabling irqs
Date: Fri, 05 Dec 2014 21:34:24 -0800 (PST)
Message-ID: <20141205.213424.884566076200225454.davem@davemloft.net>
References: <1417348611-1752-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, mlindner@marvell.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: LinoSanfilippo@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417348611-1752-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Date: Sun, 30 Nov 2014 12:56:51 +0100

> In sky2_change_mtu setting B0_IMSK to 0 may be delayed due to PCI write posting
> which could result in irqs being still active when synchronize_irq is called.
> Since we are not prepared to handle any further irqs after synchronize_irq
> (our resources are freed after that) force the write by a consecutive read from
> the same register.
> Similar situation in sky2_all_down: Here we disabled irqs by a write to B0_IMSK
> but did not ensure that this write took place before synchronize_irq. Fix that
> too.
> 
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Applied.
