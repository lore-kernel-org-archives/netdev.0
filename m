From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 82xx: FCC: Fixing a bug causing to FCC port lock-up
 (second try)
Date: Mon, 25 Jan 2016 10:47:28 -0800 (PST)
Message-ID: <20160125.104728.1314622892837934779.davem@davemloft.net>
References: <1453589779-13187-1-git-send-email-martin.roth@motorolasolutions.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: martin.roth@motorolasolutions.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453589779-13187-1-git-send-email-martin.roth@motorolasolutions.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Martin Roth <martin.roth@motorolasolutions.com>
Date: Sun, 24 Jan 2016 00:56:19 +0200

> This is an additional patch to the one already submitted recently.
> The previous patch was not complete, and the FCC port lock-up scenario
> has been reproduced in lab.
> I had an opportunity to check the current patch in lab and the FCC
> port lock no longer freezes, while the previous patch still locks-up the
> FCC port.
> The current patch fixes a pointer arithmetic bug (second bug in the same
> line), which leads FCC port lock-up during underrun/collision handling.
> Within the tx_startup() function in mac-fcc.c, the address of last BD is
> not calculated correctly. As a result of wrong calculation of the last BD
> address, the next transmitted BD may be set to an area out of the transmit
> BD ring. This actually causes to port lock-up and it is not recoverable.
> 
> Signed-off-by: Martin Roth <martin.roth@motorolasolutions.com>

Applied, thank you.
