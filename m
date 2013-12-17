From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next V1 10/11] net/mlx4_en: Fix Supported/Advertised
 link mode reported by ethtool
Date: Tue, 17 Dec 2013 19:35:45 +0200
Message-ID: <52B08B71.90006@mellanox.com>
References: <1387263720-31222-1-git-send-email-amirv@mellanox.com>	 <1387263720-31222-11-git-send-email-amirv@mellanox.com> <1387295214.1799.63.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	<netdev@vger.kernel.org>, Rana Shahout <ranas@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Eyal Perry <eyalpe@mellanox.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:44525 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754318Ab3LQRgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 12:36:15 -0500
In-Reply-To: <1387295214.1799.63.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/12/2013 17:46, Ben Hutchings wrote:
>> +		ADVERTISED_40000baseLR4_Full;
> [...]
> 
> How is this correct?  You should report the actual capabilities of the
> MAC and PHY are present, not the union of all possible modes of all the
> supported boards.
I miss-understood this field.
Will fix it.

> 
> (And the Kconfig description for MLX4_EN says '10Gbit Ethernet support',
> so if this driver now supports some 40G boards that should be updated.)
Will fix it for V2

> 
> Ben


Thanks,
Amir
