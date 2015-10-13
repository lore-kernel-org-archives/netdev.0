From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] net/fsl_pq_mdio: check TBI address for
 consistency with mapped range
Date: Tue, 13 Oct 2015 04:30:16 -0700 (PDT)
Message-ID: <20151013.043016.167211384838385409.davem@davemloft.net>
References: <1371041258-15298-1-git-send-email-ogabbay@advaoptical.com>
	<1444634321-14902-1-git-send-email-gerlando.falauto@keymile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, timur@tabi.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	ogabbay@advaoptical.com, bigeasy@linutronix.de,
	galak@kernel.crashing.org
To: gerlando.falauto@keymile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444634321-14902-1-git-send-email-gerlando.falauto@keymile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerlando Falauto <gerlando.falauto@keymile.com>
Date: Mon, 12 Oct 2015 09:18:40 +0200

> When configuring the MDIO subsystem it is also necessary to configure
> the TBI register. Make sure the TBI is contained within the mapped
> register range in order to:
> a) make sure the address is computed correctly
> b) make users aware that we're actually accessing that register
> 
> In case of error, print a message but continue anyway.
> 
> Signed-off-by: Gerlando Falauto <gerlando.falauto@keymile.com>
> Cc: Timur Tabi <timur@tabi.org>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Kumar Gala <galak@kernel.crashing.org>
> ---
> Changes from v1:
> - Added type cast & fixed range
> - removed freescale recipients

Applied.
