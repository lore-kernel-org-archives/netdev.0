From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: lpc_eth: Increase number of TX descriptors
Date: Mon, 11 Jun 2012 01:11:17 -0700 (PDT)
Message-ID: <20120611.011117.597888637750902318.davem@davemloft.net>
References: <1339401793-12258-1-git-send-email-stigge@antcom.de>
	<1339401793-12258-2-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin.wells@nxp.com,
	srinivas.bakki@nxp.com, aletes.xgr@gmail.com,
	linux-arm-kernel@lists.infradead.org
To: stigge@antcom.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339401793-12258-2-git-send-email-stigge@antcom.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Stigge <stigge@antcom.de>
Date: Mon, 11 Jun 2012 10:03:12 +0200

> Since we have enough SRAM, we can increase the number of TX descriptors, so the
> "BUSY" warning about occupied TX descriptors doesn't need to show up as often.
> 
> Signed-off-by: Roland Stigge <stigge@antcom.de>
> Tested-by: Alexandre Pereira da Silva <aletes.xgr@gmail.com>

This is way too terse, and as I described in my reply to your first
patch it is not normal for the transmit function to be invoked when
there are no TX descriptors available.  That's a bug if it is happening.
