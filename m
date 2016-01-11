From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bfin_mac: fix error path
Date: Sun, 10 Jan 2016 22:46:31 -0500 (EST)
Message-ID: <20160110.224631.2297924959622557260.davem@davemloft.net>
References: <1452252495-20961-1-git-send-email-sudipm.mukherjee@gmail.com>
	<1452252495-20961-2-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	andrew@lunn.ch
To: sudipm.mukherjee@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452252495-20961-2-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Date: Fri,  8 Jan 2016 16:58:15 +0530

> While building blackfin defconfig we were getting a build warning:
> warning: label 'out_err_irq_alloc' defined but not used.
> 
> Commit e7f4dc3536a4 ("mdio: Move allocation of interrupts into core")
> removed the label out_err_mdiobus_register but then mistakenly jumped to
> out_err_alloc. But it was actually supposed to jump to out_err_irq_alloc.
> 
> Fixes: e7f4dc3536a4 ("mdio: Move allocation of interrupts into core")
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>

Applied.
