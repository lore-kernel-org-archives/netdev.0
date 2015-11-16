From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: irq_fpu_usable() is false in ndo_start_xmit() for UDP packets
Date: Mon, 16 Nov 2015 22:28:52 +0100
Message-ID: <CAHmME9qDJnfJgerxwwG8_dMvse7oim=sDdPzQo=DRi_S0Ym=Ew@mail.gmail.com>
References: <CAHmME9qQz-uTFDjUuVaqpO9ODt3KZWEdYVQJ8qsXWa5YkYAoWA@mail.gmail.com>
	<20151116.153214.1125103075112383723.davem@davemloft.net>
	<CAHmME9o3s5iTZ4gcFVQ1xTu9PaaLjkEGcvhJRF+S=0GugxhQ8Q@mail.gmail.com>
	<20151116.161746.1472467067664450149.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:54125 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751829AbbKPV25 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2015 16:28:57 -0500
In-Reply-To: <20151116.161746.1472467067664450149.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 16, 2015 at 10:17 PM, David Miller <davem@davemloft.net> wrote:
>
> Not without a complete redesign of the x86 fpu save/restore mechanism.

Urg, okay. I still wonder why irq_fpu_usable() is true when using TCP but not
when using UDP... Any ideas on this?

> The driver is the wrong place to do software cryptographic transforms
> anyways.
> Judging from your other emails, you doing a lot of weird shit in your
> driver.
> Maybe you should just tell us exactly what kind of device it is for,
> exactly what the features and offloads are, and maybe we can tell you
> therefore what kind of facilities would match that situation best.
> You're currently trying to do it the other way, you know everything
> about your device and goals, and you're sending us small piecemeal
> questions.  We lack the high level full picture of your device, so
> it's hard for us to give you good answers.

Yes, this is fair to ask. Here it goes:

I'm making a simpler replacement for IPSec that operates as an device
driver on the interface level, rather than the IPSec xfrm method. The
methodology is going to be controversial, so I'm taking my time
perfecting each component, and then I'm planning on writing in with a
big email explaining why, with justifications, and numbers. It has
some real world benefits that are already quantifiable. If you're
curious, I did a talk on it at Kernel Recipes in Paris [1]. But
please, give me some time to finish things and prepare myself. I want
to present it to you in the best way possible. I'd hate for it to be
dismissed too early or too hastily, before it's had its chance.

[1] https://www.youtube.com/watch?v=9Rk4doELmwM
