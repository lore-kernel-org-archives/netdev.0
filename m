From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v2 1/1] drivers: net: cpsw: fix disabling of tx
 interrupt in rx isr
Date: Thu, 09 Jul 2015 14:54:04 -0700 (PDT)
Message-ID: <20150709.145404.679352676923852906.davem@davemloft.net>
References: <1436346322-4455-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, balbi@ti.com, stable@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1436346322-4455-1-git-send-email-mugunthanvnm@ti.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Wed, 8 Jul 2015 14:35:22 +0530

> In commit 'c03abd84634d ("net: ethernet: cpsw: don't requests
> IRQs we don't use")', common isr is split into tx and rx, but
> in rx isr tx interrupt is also disabledi in cpsw_disable_irq().
> So tx interrupts are not handled during rx interrupts and rx
> napi completion and results in poor tx performance by 40Mbps.
> Fixing by disabling only rx interrupt in rx isr.
> 
> Cc: Felipe Balbi <balbi@ti.com>
> Cc: <stable@vger.kernel.org> # v4.0+
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied, thanks.
