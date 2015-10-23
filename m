From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/phy: micrel: Add workaround for bad autoneg
Date: Fri, 23 Oct 2015 02:57:48 -0700 (PDT)
Message-ID: <20151023.025748.1019942494326757711.davem@davemloft.net>
References: <1445455024-5519-1-git-send-email-nathan.sullivan@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nathan.sullivan@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445455024-5519-1-git-send-email-nathan.sullivan@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nathan Sullivan <nathan.sullivan@ni.com>
Date: Wed, 21 Oct 2015 14:17:04 -0500

> Very rarely, the KSZ9031 will appear to complete autonegotiation, but
> will drop all traffic afterwards.  When this happens, the idle error
> count will read 0xFF after autonegotiation completes.  Reset the PHY
> when in that state.
> 
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>

Applied, thanks.
