From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] net: sfc: fix return value check in
 efx_ptp_probe_channel().
Date: Wed, 12 Dec 2012 00:15:50 -0500 (EST)
Message-ID: <20121212.001550.741463250196231082.davem@davemloft.net>
References: <1355271894-5284-1-git-send-email-tipecaml@gmail.com>
	<1355271894-5284-5-git-send-email-tipecaml@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-net-drivers@solarflare.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: tipecaml@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1355271894-5284-5-git-send-email-tipecaml@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyril Roelandt <tipecaml@gmail.com>
Date: Wed, 12 Dec 2012 01:24:53 +0100

> The ptp_clock_register() returns ERR_PTR() and never returns NULL. Replace the
> NULL check by a call to IS_ERR().
> 
> Signed-off-by: Cyril Roelandt <tipecaml@gmail.com>

I'll let Ben queue this up.

Probably he'll want to avoid potentially leaving an ERR_PTR
in ptp->phc_clock even if, with this fix, that would be
harmless.
