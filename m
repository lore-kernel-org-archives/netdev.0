From: "Mathieu Olivari" <mathieu@codeaurora.org>
Subject: RE: [PATCH 4/5] stmmac: add ipq806x glue layer
Date: Wed, 27 May 2015 09:10:16 -0700
Message-ID: <004d01d09897$a06f8090$e14e81b0$@codeaurora.org>
References: <1432668437-27763-1-git-send-email-mathieu@codeaurora.org>	 <1432668437-27763-5-git-send-email-mathieu@codeaurora.org> <1432710218.27695.215.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<mturquette@linaro.org>, <sboyd@codeaurora.org>,
	<peppe.cavallaro@st.com>, <agross@codeaurora.org>,
	<joshc@codeaurora.org>, <architt@codeaurora.org>,
	<georgi.djakov@linaro.org>, <wsa@the-dreams.de>,
	<rnayak@codeaurora.org>, <davem@davemloft.net>,
	<vbridger@opensource.altera.com>, <devicetree@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-clk@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: "'Paul Bolle'" <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432710218.27695.215.camel@x220>
Content-Language: en-us
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My bad. This is ISC license. MODULE_LICENSE should actually be "Dual BSD/GPL".
Same license is used in other places in the kernel like drivers/net/wireless/ath/ath10k/pci.c.
I'll post a v2.
Thanks,
Mathieu

-----Original Message-----
From: Paul Bolle [mailto:pebolle@tiscali.nl] 
Sent: Wednesday, May 27, 2015 12:04 AM
To: Mathieu Olivari
Cc: robh+dt@kernel.org; pawel.moll@arm.com; mark.rutland@arm.com; ijc+devicetree@hellion.org.uk; galak@codeaurora.org; mturquette@linaro.org; sboyd@codeaurora.org; peppe.cavallaro@st.com; agross@codeaurora.org; joshc@codeaurora.org; architt@codeaurora.org; georgi.djakov@linaro.org; wsa@the-dreams.de; rnayak@codeaurora.org; davem@davemloft.net; vbridger@opensource.altera.com; devicetree@vger.kernel.org; linux-kernel@vger.kernel.org; linux-clk@vger.kernel.org; netdev@vger.kernel.org
Subject: Re: [PATCH 4/5] stmmac: add ipq806x glue layer

Just a nit: a license mismatch.

On Tue, 2015-05-26 at 12:27 -0700, Mathieu Olivari wrote:
> --- /dev/null
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c

> + * Permission to use, copy, modify, and/or distribute this software 
> + for any
> + * purpose with or without fee is hereby granted, provided that the 
> + above
> + * copyright notice and this permission notice appear in all copies.
> + *
> + * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL 
> + WARRANTIES
> + * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
> + * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE 
> + LIABLE FOR
> + * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY 
> + DAMAGES
> + * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN 
> + AN
> + * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING 
> + OUT OF
> + * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

I have no idea which license this is.

> +MODULE_LICENSE("GPL");

But I do know that it's not GPL v2 or later (see include/linux/module.h).


Paul Bolle
