From: Mark Jackson <mpfj-list@mimc.co.uk>
Subject: Re: [PATCH v3 net-next 1/1] drivers: net: davinci_cpdma: acknowledge
 interrupt properly
Date: Wed, 13 Mar 2013 09:34:48 +0000
Message-ID: <51404838.2040008@mimc.co.uk>
References: <1361175560-600-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1361175560-600-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18/02/13 08:19, Mugunthan V N wrote:
> CPDMA interrupts are not properly acknowledged which leads to interrupt
> storm, only cpdma interrupt 0 is acknowledged in Davinci CPDMA driver.
> Changed cpdma_ctlr_eoi api to acknowledge 1 and 2 interrupts which are
> used for rx and tx respectively.
> 
> Reported-by: Pantelis Antoniou <panto@antoniou-consulting.com>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Not sure if I'm seeing this same problem [1], but it doesn't appear fixed to me.

I've tried both mainline -rc2 and -next.

[1] https://lkml.org/lkml/2013/3/12/376

Regards
Mark J.
