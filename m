From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/3] rcar_can: print signed IRQ #
Date: Sat, 20 Jun 2015 19:25:24 +0300
Message-ID: <558593F4.1080402@cogentembedded.com>
References: <2010452.WyFito6egU@wasted.cogentembedded.com> <2390389.thI8mIvbv5@wasted.cogentembedded.com> <CAMuHMdWZFKR04NJc7xtnPUosYuosX9FPDJopG3wovu_GqGxSOw@mail.gmail.com> <55857AD3.4040000@cogentembedded.com> <55858E8B.9000801@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	wg@grandegger.com, linux-can@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <55858E8B.9000801@pengutronix.de>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 6/20/2015 7:02 PM, Marc Kleine-Budde wrote:

>>>> Printing IRQ # using "%x" and "%u" unsigned formats isn't quite correct as
>>>> 'ndev->irq' is of  type *int*, so  the "%d" format  needs to be used instead.

>>>> While fixing this, beautify the dev_info() message in rcar_can_probe() a bit.

>>> If you change the message, why don't you make it consistent
>>> ("interrupt" vs. "IRQ")?

>>      I decided to change the message in a follow-up patch (posted afterwards).

> Please squash you patches, so that you don't modify code (or error
> messages) that you've added in a previous patch.

    I didn't add any messages.

> Marc

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-sh" in
