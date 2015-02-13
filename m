From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH] Revert "smc91x: retrieve IRQ and trigger flags in a modern way"
Date: Fri, 13 Feb 2015 09:12:29 +0100
Message-ID: <87fvaa5ixe.fsf@free.fr>
References: <1423760350-20149-1-git-send-email-robert.jarzmik@free.fr>
	<CACRpkdZGze_2=hWe414Eum_9hpNXgog5vmu6Y4R_zhg0x2z0SQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACRpkdZGze_2=hWe414Eum_9hpNXgog5vmu6Y4R_zhg0x2z0SQ@mail.gmail.com>
	(Linus Walleij's message of "Fri, 13 Feb 2015 10:16:09 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Walleij <linus.walleij@linaro.org> writes:

> On Fri, Feb 13, 2015 at 12:59 AM, Robert Jarzmik <robert.jarzmik@free.fr> wrote:
> But isn't the real problem that in the device tree case,
> irq_get_irq_data(ndev->irq) will work becaus parsing an interrupt
> from the device tree populates it correctly in platform_get_irq()
> whereas for the legacy lookup it just fetches the number.
>
> So to me it seems like a weakness in the platform_get_irq()
> helper altogether.
>
> Does the following work? (I can send as a separate patch for
> testing if you like).

I will test this evening (GMT+1 time), I feel this will work, and that this
solution looks better to me than the sheer revert. I don't ask for a separate
patch, yet if it is confirmed that it works, you'll have to submit it anyway :)

Cheers.

--
Robert
