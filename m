From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: davinci_mdio: reuse for keystone2 arch
Date: Wed, 09 Jul 2014 16:52:32 -0700 (PDT)
Message-ID: <20140709.165232.539576872991411664.davem@davemloft.net>
References: <1404911451-9921-1-git-send-email-grygorii.strashko@ti.com>
	<1404911451-9921-2-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, santosh.shilimkar@ti.com,
	netdev@vger.kernel.org, prabhakar.csengg@gmail.com, nsekhar@ti.com,
	robh+dt@kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404911451-9921-2-git-send-email-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Wed, 9 Jul 2014 16:10:50 +0300

>  Required properties:
> -- compatible		: Should be "ti,davinci_mdio"
> +- compatible		: Should be "ti,davinci_mdio" or "ti,keystone-mdio"

Why the inconsistency in naming schemes?  I don't see any reason
to be different wrt. "_" vs. "-" in the name string.
