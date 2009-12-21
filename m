From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH 0/4] mx25: add support for FEC on i.MX25 PDK
Date: Mon, 21 Dec 2009 08:04:30 +0200
Message-ID: <20091221060429.GA3569@jasper.tkos.co.il>
References: <cover.1260785451.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Sascha Hauer <kernel@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:48992 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751053AbZLUGFy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Dec 2009 01:05:54 -0500
Content-Disposition: inline
In-Reply-To: <cover.1260785451.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sascha,

Ping.

Ack/NACK?

baruch

On Mon, Dec 14, 2009 at 12:19:38PM +0200, Baruch Siach wrote:
> This patch series adds support for the FEC peripheral of the i.MX25 on the 
> i.MX25 PDK board.
> 
> The first two patches are fixes for compilation and run failures. The third 
> patch enables RMII if the FEC driver. Finally, the last patch adds the 
> necessary board support code (pads, clock, etc.)
> 
> The FEC fix seems like an ugly hack to me. Suggestions for a better solution 
> are welcome.
> 
> Baruch Siach (4):
>   mx25: s/NO_PAD_CTL/NO_PAD_CTRL/
>   mx25: don't force input on FEC pins
>   fec: add support for Freescale i.MX25 PDK (3DS)
>   mx25: add support for FEC on i.MX25 PDK
> 
>  arch/arm/mach-mx25/clock.c                  |    2 +
>  arch/arm/mach-mx25/devices.c                |   19 ++++++++
>  arch/arm/mach-mx25/devices.h                |    1 +
>  arch/arm/mach-mx25/mx25pdk.c                |   40 ++++++++++++++++-
>  arch/arm/plat-mxc/include/mach/iomux-mx25.h |   64 +++++++++++++-------------
>  arch/arm/plat-mxc/include/mach/mx25.h       |    4 ++
>  drivers/net/fec.c                           |   22 +++++++++
>  drivers/net/fec.h                           |    2 +
>  8 files changed, 121 insertions(+), 33 deletions(-)

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
