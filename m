From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 82xx: FCC: Fixing a bug causing to FCC port lock-up
Date: Wed, 16 Dec 2015 18:32:53 -0500 (EST)
Message-ID: <20151216.183253.313939933312742383.davem@davemloft.net>
References: <1450145874-9750-1-git-send-email-martin.roth@motorolasolutions.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: martin.roth@motorolasolutions.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1450145874-9750-1-git-send-email-martin.roth@motorolasolutions.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Martin Roth <martin.roth@motorolasolutions.com>
Date: Tue, 15 Dec 2015 04:17:53 +0200

> The patch fixes FCC port lock-up, which occurs as a result of a bug
> during underrun/collision handling. Within the tx_startup() function
> in mac-fcc.c, the address of last BD is not calculated correctly.
> As a result of wrong calculation of the last BD address, the next
> transmitted BD may be set to an area out of the transmit BD ring.
> This actually causes to port lock-up and it is not recoverable.
> 
> Signed-off-by: Martin Roth <martin.roth@motorolasolutions.com>

Applied, thanks.
