From: David Miller <davem@davemloft.net>
Subject: Re: irq_fpu_usable() is false in ndo_start_xmit() for UDP packets
Date: Mon, 16 Nov 2015 16:17:46 -0500 (EST)
Message-ID: <20151116.161746.1472467067664450149.davem@davemloft.net>
References: <CAHmME9qQz-uTFDjUuVaqpO9ODt3KZWEdYVQJ8qsXWa5YkYAoWA@mail.gmail.com>
	<20151116.153214.1125103075112383723.davem@davemloft.net>
	<CAHmME9o3s5iTZ4gcFVQ1xTu9PaaLjkEGcvhJRF+S=0GugxhQ8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason@zx2c4.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9o3s5iTZ4gcFVQ1xTu9PaaLjkEGcvhJRF+S=0GugxhQ8Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Mon, 16 Nov 2015 21:58:49 +0100

> That is extremely problematic for me. Is there a way to make this
> not so?

Not without a complete redesign of the x86 fpu save/restore mechanism.

The driver is the wrong place to do software cryptographic transforms
anyways.

Judging from your other emails, you doing a lot of weird shit in your
driver.

Maybe you should just tell us exactly what kind of device it is for,
exactly what the features and offloads are, and maybe we can tell you
therefore what kind of facilities would match that situation best.

You're currently trying to do it the other way, you know everything
about your device and goals, and you're sending us small piecemeal
questions.  We lack the high level full picture of your device, so
it's hard for us to give you good answers.
