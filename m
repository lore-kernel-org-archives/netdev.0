From: Dinh Nguyen <dinh.linux@gmail.com>
Subject: Re: [PATCH v6 4/4] stmmac: socfpga: Provide dt node to config ptp clk source.
Date: Mon, 14 Dec 2015 15:16:10 -0600
Message-ID: <CADhT+wesDDATNR1dX8ynjKKfm3tUv7_TSyZ80kCgGcr9gYcfBg@mail.gmail.com>
References: <1450063922-19481-1-git-send-email-preid@electromag.com.au>
	<1450063922-19481-5-git-send-email-preid@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	David Miller <davem@davemloft.net>,
	"vbridger@opensource.altera.com" <vbridger@opensource.altera.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	netdev@vger.kernel.org
To: Phil Reid <preid@electromag.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:34939 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932080AbbLNVQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 16:16:11 -0500
In-Reply-To: <1450063922-19481-5-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 13, 2015 at 9:32 PM, Phil Reid <preid@electromag.com.au> wrote:
> Provides an options to use the ptp clock routed from the Altera FPGA
> fabric. Instead of the defalt eosc1 clock connected to the ARM HPS core.
> This setting affects all emacs in the core as the ptp clock is common.
>
> Acked-by: Rob Herring <robh@kernel.org>
> Signed-off-by: Phil Reid <preid@electromag.com.au>
> ---
>  Documentation/devicetree/bindings/net/socfpga-dwmac.txt | 2 ++
>  drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c     | 9 +++++++++
>  2 files changed, 11 insertions(+)
>

Acked-by: Dinh Nguyen <dinguyen@opensource.altera.com>

Dinh
