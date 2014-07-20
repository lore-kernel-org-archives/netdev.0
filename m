From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: FEC driver hangs hardware on i.MX6SX
Date: Sun, 20 Jul 2014 08:20:49 +0200
Message-ID: <20140720062048.GB5686@netboy>
References: <20140720025732.GF8537@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fugang Duan <B38611@freescale.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Frank Li <Frank.li@freescale.com>,
	"David S. Miller" <davem@davemloft.net>
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:44502 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039AbaGTGVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 02:21:01 -0400
Received: by mail-we0-f177.google.com with SMTP id w62so6176793wes.36
        for <netdev@vger.kernel.org>; Sat, 19 Jul 2014 23:20:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140720025732.GF8537@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 20, 2014 at 10:57:33AM +0800, Shawn Guo wrote:
> 
> I think the cause is that PTP is still accessing registers after FEC
> driver calls fec_enet_clk_enable(ndev, false) to disable FEC clocks.
> Can you please try to provide a fix for this regression soon?

What do you mean by, "PTP is still accessing registers"?

The only access to any register is through the driver, and the driver
can and should make sure all register accesses are safe.

Thanks,
Richard
