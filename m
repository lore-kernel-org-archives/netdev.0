From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 2/3] drivers: net: cpsw: fix error messages when using
 phy-handle DT property
Date: Tue, 29 Dec 2015 14:30:34 -0600
Message-ID: <20151229203034.GA18528@rob-hp-laptop>
References: <1450830994-5450-1-git-send-email-drivshin.allworx@gmail.com>
 <1450830994-5450-3-git-send-email-drivshin.allworx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, devicetree@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Heiko Schocher <hs@denx.de>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	Pascal Speck <kernel@iktek.de>,
	Daniel Trautmann <dtrautmann@ibhsoftec-sps.de>
To: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:46546 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753785AbbL2Uaj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Dec 2015 15:30:39 -0500
Content-Disposition: inline
In-Reply-To: <1450830994-5450-3-git-send-email-drivshin.allworx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 22, 2015 at 07:36:33PM -0500, David Rivshin (Allworx) wrote:
> From: David Rivshin <drivshin@allworx.com>
> 
> The phy-handle, phy_id, and fixed-link properties are mutually exclusive,
> and only one need be specified. However if phy-handle was specified, an
> error message would complain about the lack of phy_id or fixed-link.
> 
> Also, if phy-handle was specified and the subsequent of_phy_connect()
> failed, the error message still referenced slaved->data->phy_id, which
> would be empty. Instead, use the name of the device_node as a useful
> identifier.
> 
> Fixes: 9e42f715264f ("drivers: net: cpsw: add phy-handle parsing")
> Signed-off-by: David Rivshin <drivshin@allworx.com>
> ---
> This would require some adjustments to backport to 4.3-stable due to
> other changes in this area. Let me know if you want a version of this
> against v4.3.3.
> 
>  Documentation/devicetree/bindings/net/cpsw.txt |  4 ++--

For the binding:

Acked-by: Rob Herring <robh@kernel.org>
