From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 2/2 (linux-stable-4.5.y)] stmmac: fix MDIO settings
Date: Sun, 14 Aug 2016 17:44:41 +0200
Message-ID: <20160814154441.GJ20560@kroah.com>
References: <1464009463-23654-1-git-send-email-peppe.cavallaro@st.com>
 <1464009463-23654-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: stable@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, robin.murphy@arm.com, marc.zyngier@arm.com,
	afaerber@suse.de, bert@a20.net, linux-sunxi@googlegroups.com,
	maxime.ripard@free-electrons.com,
	Gabriel Fernandez <gabriel.fernandez@linaro.org>,
	Dinh Nguyen <dinh.linux@gmail.com>,
	"David S . Miller" <davem@davemloft.net>,
	Phil Reid <preid@electromag.com.au>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:47882 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752170AbcHNPob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 11:44:31 -0400
Content-Disposition: inline
In-Reply-To: <1464009463-23654-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 23, 2016 at 03:17:43PM +0200, Giuseppe Cavallaro wrote:
> Initially the phy_bus_name was added to manipulate the
> driver name but it was recently just used to manage the
> fixed-link and then to take some decision at run-time.
> So the patch uses the is_pseudo_fixed_link and removes
> the phy_bus_name variable not necessary anymore.
> 
> The driver can manage the mdio registration by using phy-handle,
> dwmac-mdio and own parameter e.g. snps,phy-addr.
> This patch takes care about all these possible configurations
> and fixes the mdio registration in case of there is a real
> transceiver or a switch (that needs to be managed by using
> fixed-link).
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Reviewed-by: Andreas Färber <afaerber@suse.de>
> Tested-by: Frank Schäfer <fschaefer.oss@googlemail.com>
> Cc: Gabriel Fernandez <gabriel.fernandez@linaro.org>
> Cc: Dinh Nguyen <dinh.linux@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Phil Reid <preid@electromag.com.au>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 11 +--
>  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  | 19 +----
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 84 +++++++++++++++++-----
>  3 files changed, 70 insertions(+), 44 deletions(-)

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>
