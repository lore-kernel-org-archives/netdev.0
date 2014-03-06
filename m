From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: Re: [PATCH] net: davinci_emac: Replace devm_request_irq with request_irq
Date: Thu, 6 Mar 2014 11:08:18 +0530
Message-ID: <CA+V-a8u3HChveLMuncWmXpeMhFgj1Bj4urLK1-gCOafAd0JxVg@mail.gmail.com>
References: <2ec3bb89-89db-48e8-b360-369545a2546f@mary.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, Jon Ringle <jon@ringle.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	dlos <davinci-linux-open-source@linux.davincidsp.com>,
	stable@vger.kernel.org
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <2ec3bb89-89db-48e8-b360-369545a2546f@mary.at.omicron.at>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Christian,

Thanks for the patch.

On Wed, Mar 5, 2014 at 3:55 PM, Christian Riesch
<christian.riesch@omicron.at> wrote:
> In commit 6892b41d9701283085b655c6086fb57a5d63fa47
>
> Author: Lad, Prabhakar <prabhakar.csengg@gmail.com>
> Date:   Tue Jun 25 21:24:51 2013 +0530
> net: davinci: emac: Convert to devm_* api
>
> the call of request_irq is replaced by devm_request_irq and the call
> of free_irq is removed. But since interrupts are requested in
> emac_dev_open, doing ifconfig up/down on the board requests the
> interrupts again each time, causing devm_request_irq to fail.
>
> This patch reverts said commit partially: It changes the driver back
> to use request_irq instead of devm_request_irq, puts free_irq back in
> place, but keeps the remaining changes of the original patch.
>
> Reported-by: Jon Ringle <jon@ringle.org>
> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
> Cc: Lad, Prabhakar <prabhakar.csengg@gmail.com>
> Cc: <stable@vger.kernel.org>

Acked-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Regards,
--Prabhakar lad
