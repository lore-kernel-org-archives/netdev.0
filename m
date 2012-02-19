From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/atm/solos-pci.c: exchange pci_iounmaps
Date: Sun, 19 Feb 2012 18:58:32 -0500 (EST)
Message-ID: <20120219.185832.570250355385915096.davem@davemloft.net>
References: <1329680612-28055-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, kernel-janitors@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329680612-28055-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun, 19 Feb 2012 20:43:32 +0100

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> The calls to pci_iounmap are in the wrong order, as compared to the
> associated calls to pci_iomap.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Good catch, applied.
