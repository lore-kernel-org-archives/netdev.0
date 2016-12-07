From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: do not call phy_ethtool_ksettings_set
 from atomic context
Date: Wed, 07 Dec 2016 13:09:14 -0500 (EST)
Message-ID: <20161207.130914.1091695245299713548.davem@davemloft.net>
References: <1481032035-19018-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com, niklass@axis.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: niklas.cassel@axis.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481032035-19018-1-git-send-email-niklass@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>
Date: Tue, 6 Dec 2016 14:47:15 +0100

> From: Niklas Cassel <niklas.cassel@axis.com>
> 
> From what I can tell, spin_lock(&priv->lock) is not needed, since the
> phy_ethtool_ksettings_set call is not given the priv struct.
> 
> phy_start_aneg takes the phydev->lock. Calls to phy_adjust_link
> from phy_state_machine also takes the phydev->lock.
...
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>

Applied, but please always be explicit about what tree you are targetting
this patch by properly annotating for it in your Subject line.

In this case that would be "Subject: [PATCH net-next] ..."
