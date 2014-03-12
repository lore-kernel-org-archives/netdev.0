From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next V4 5/9] Altera TSE: Add Miscellaneous Files for
 Altera Ethernet Driver
Date: Wed, 12 Mar 2014 13:34:35 -0700
Message-ID: <1394656475.3915.35.camel@joe-AO722>
References: <1394655334-29547-1-git-send-email-vbridgers2013@gmail.com>
	 <1394655334-29547-6-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, rob@landley.net
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1394655334-29547-6-git-send-email-vbridgers2013@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-03-12 at 15:15 -0500, Vince Bridgers wrote:
> This patch adds miscellaneous files for the Altera Ethernet Driver,
> including ethtool support.
> 
> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
> ---
> V4: - Change names of statistics to match common usage found in most
>       drivers instead of TSE databook names.
>     - Remove unnecessary cast

thanks, maybe this one thing below:

> diff --git a/drivers/net/ethernet/altera/altera_tse_ethtool.c b/drivers/net/ethernet/altera/altera_tse_ethtool.c

> +static char const stat_gstrings[][ETH_GSTRING_LEN] = {

static const char


