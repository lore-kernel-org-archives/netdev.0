From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mvneta: add forgotten initialization of
 autonegotiation bits
Date: Tue, 23 Jun 2015 02:33:51 -0700 (PDT)
Message-ID: <20150623.023351.212943884120317727.davem@davemloft.net>
References: <5582E563.3010801@list.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	netdev@vger.kernel.org, f.fainelli@gmail.com,
	thomas.petazzoni@free-electrons.com, arno@natisbad.org,
	stsp@users.sourceforge.net
To: stsp@list.ru
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <5582E563.3010801@list.ru>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stas Sergeev <stsp@list.ru>
Date: Thu, 18 Jun 2015 18:36:03 +0300

> 
> The commit 898b2970e2c9 ("mvneta: implement SGMII-based in-band link state
> signaling")
> changed mvneta_adjust_link() so that it does not clear the auto-negotiation
> bits in MVNETA_GMAC_AUTONEG_CONFIG register. This was necessary for
> auto-negotiation mode to work.
> Unfortunately I haven't checked if these bits are ever initialized.
> It appears they are not.
> This patch adds the missing initialization of the auto-negotiation bits
> in the MVNETA_GMAC_AUTONEG_CONFIG register.
> It fixes the following regression:
> https://www.mail-archive.com/netdev@vger.kernel.org/msg67928.html
> 
> Since the patch was tested to fix a regression, it should be applied to
> stable tree.
> 
> Tested-by: Arnaud Ebalard <arno@natisbad.org>
> 
> CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> CC: Florian Fainelli <f.fainelli@gmail.com>
> CC: netdev@vger.kernel.org
> CC: linux-kernel@vger.kernel.org
> CC: stable@vger.kernel.org
> 
> Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>

Applied, thanks.
