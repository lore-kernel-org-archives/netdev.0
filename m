From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: fix uninitalized ethtool_wolinfo in
 phy_suspend
Date: Fri, 14 Mar 2014 22:39:25 -0400 (EDT)
Message-ID: <20140314.223925.1612925351139021751.davem@davemloft.net>
References: <20140313.153832.967564223480298567.davem@davemloft.net>
	<1394788064-6832-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, ben@decadent.org.uk, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394788064-6832-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Date: Fri, 14 Mar 2014 10:07:44 +0100

> Callers of phy_ethtool_get_wol are supposed to provide a properly
> cleared struct ethtool_wolinfo. Therefore, fix phy_suspend to clear
> it before passing it to phy_ethtool_get_wol.
> 
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

Applied, thanks.
