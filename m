From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH net-next 1/2] Revert "ARM: imx: add FEC sleep mode
 callback function"
Date: Thu, 8 Jan 2015 20:53:51 +0800
Message-ID: <20150108125349.GD4928@dragon>
References: <1420634393-30027-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, fugang.duan@freescale.com,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:50478 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753240AbbAHMyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 07:54:19 -0500
Received: by mail-pd0-f176.google.com with SMTP id r10so11102152pdi.7
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 04:54:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1420634393-30027-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2015 at 10:39:52AM -0200, Fabio Estevam wrote:
> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> i.MX platform maintainer Shawn Guo is not happy with the such commit as
> explained below [1]:
> 
> "The GPR difference between SoCs can be encoded in device tree as well.
> It's pointless to repeat the same code pattern for every single
> platform, that need to set up GPR bits for enabling magic packet wake
> up, while the only difference is the register and bit offset.
> 
> The platform code will become quite messy and unmaintainable if every
> device driver dump their GPR register setup code into platform.
> 
> Sorry, but it's NACK from me."
> 
> This reverts commit 456062b3ec6f5b9 ("ARM: imx: add FEC sleep mode callback 
> function").
> 
> [1] http://www.spinics.net/lists/netdev/msg310922.html
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Thanks, Fabio.  For both patches,

Acked-by: Shawn Guo <shawn.guo@linaro.org>
