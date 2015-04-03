From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/2] mvneta: SGMII-based in-band link state signaling
Date: Fri, 03 Apr 2015 15:08:37 -0400 (EDT)
Message-ID: <20150403.150837.1808334906292015688.davem@davemloft.net>
References: <551C2AB9.8020508@list.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stsp@users.sourceforge.net
To: stsp@list.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <551C2AB9.8020508@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stas Sergeev <stsp@list.ru>
Date: Wed, 01 Apr 2015 20:28:25 +0300

> Currently the fixed-link DT binding is pre-configured and
> cannot be changed in run-time. This means the cable unplug
> events are not being detected, and the link parameters can't
> be negotiated.
> 
> The following patches are needed when mvneta is used
> in fixed-link mode (without MDIO).
> They add an API to fixed_phy that allows to update
> status, and use that API in the mvneta driver when parsing
> the SGMII in-band status.
> 
> There is also another implementation that doesn't add any API
> and does everything in mvneta driver locally:
> https://lkml.org/lkml/2015/3/31/327
> I'll let people decide which approach is better.
> No strong opinion on my side.
> 
> Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>

Series applied, thanks.
