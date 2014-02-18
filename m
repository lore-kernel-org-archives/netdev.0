From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH v2] net: ethernet: update dependency and help text of
 mvneta
Date: Tue, 18 Feb 2014 09:06:04 -0500
Message-ID: <20140218140604.GO7862@titan.lakedaemon.net>
References: <1392729491-24913-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-02-ewr.mailhop.org ([204.13.248.72]:59774 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755636AbaBROGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 09:06:17 -0500
Content-Disposition: inline
In-Reply-To: <1392729491-24913-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 18, 2014 at 02:18:11PM +0100, Thomas Petazzoni wrote:
> With the introduction of the support for Armada 375 and Armada 38x,
> the hidden Kconfig option MACH_ARMADA_370_XP is being renamed to
> MACH_MVEBU_V7. Therefore, the dependency that was used for the mvneta
> driver can no longer work. This commit replaces this dependency by a
> dependency on PLAT_ORION, which is used similarly for the mv643xx_eth
> driver.
> 
> In addition to this, it takes this opportunity to adjust the
> description and help text to indicate that the driver can is also used
> for Armada 38x. Note that Armada 375 cannot use this driver as it has
> a completely different networking unit, which will require a separate
> driver.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> ---
> Changes since v1:
>  - Instead of removing the Kconfig dependency, replace it by a
>    dependency on PLAT_ORION, in order to avoid building mvneta on too
>    many architectures and getting weird build issues. Suggested by
>    Jason Cooper.
>  - Fix capitalization in the Kconfig help text.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> ---
>  drivers/net/ethernet/marvell/Kconfig | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)

Acked-by: Jason Cooper <jason@lakedaemon.net>

thx,

Jason.
