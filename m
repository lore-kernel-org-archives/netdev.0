From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: fix NULL pointer dereference in
 fec_enet_timeout_work
Date: Thu, 08 Jan 2015 20:12:56 -0800 (PST)
Message-ID: <20150108.201256.84753051983146804.davem@davemloft.net>
References: <1420638497-6871-1-git-send-email-hubert.feurstein@deto.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fabio.estevam@freescale.com,
	frank.li@freescale.com, linux-kernel@vger.kernel.org
To: h.feurstein@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420638497-6871-1-git-send-email-hubert.feurstein@deto.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hubert Feurstein <h.feurstein@gmail.com>
Date: Wed,  7 Jan 2015 14:48:17 +0100

> From: Hubert Feurstein <h.feurstein@gmail.com>
> 
> This patch initialises the fep->netdev pointer. This pointer was not
> initialised at all, but is used in fec_enet_timeout_work and in some
> error paths.
> 
> Signed-off-by: Hubert Feurstein <h.feurstein@gmail.com>

Applied.
