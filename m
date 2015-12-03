From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] mvneta: implement ethtool autonegotiation control
Date: Thu, 03 Dec 2015 15:18:35 -0500 (EST)
Message-ID: <20151203.151835.2096865567050500953.davem@davemloft.net>
References: <565F2B28.4080501@list.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	thomas.petazzoni@free-electrons.com, linux@arm.linux.org.uk
To: stsp@list.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <565F2B28.4080501@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stas Sergeev <stsp@list.ru>
Date: Wed, 2 Dec 2015 20:32:24 +0300

> These 2 patches add an ability to control the
> autonegotiation via ethtool. For example:
> 
> ethtool -s eth0 autoneg off
> ethtool -s eth0 autoneg on
> 
> This is needed if you want to connect the mvneta's MII
> to different switches or PHYs: the ones the do support
> the in-band status, and the ones that do not.

Series applied to net-next, thanks.
