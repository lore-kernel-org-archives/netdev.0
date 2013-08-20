From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pch_gbe: ethtool cannot change parameters when link is
 down
Date: Tue, 20 Aug 2013 15:07:39 -0700 (PDT)
Message-ID: <20130820.150739.295329075883411467.davem@davemloft.net>
References: <1376819680-15359-1-git-send-email-al@alarsen.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: al@alarsen.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376819680-15359-1-git-send-email-al@alarsen.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anders Larsen <al@alarsen.net>
Date: Sun, 18 Aug 2013 11:54:40 +0200

> When attempting to change e.g. the advertising mask when the link is down
> ecmd->speed is -1 causing mii_ethtool_sset() to bail out.
> 
> This bug bit when connecting to a gigabit switch through a 4-pin (industrial)
> cable, since link negotiation would not complete (both endpoints claimed to
> be gigabit-capable, but this is not possible with only 4 pins).
> Any attempt to fix this by setting autonegation to not offer 1000Mbps
> failed as the setting would not be accepted while the link was still down...
> 
> Set ecmd->speed to SPEED_1000 to satisfy mii_ethtool_sset()
> (the actual value of ecmd->speed doesn't matter as long as it is valid,
> since a re-negotation is forced afterwards).
> 
> Signed-off-by: Anders Larsen <al@alarsen.net>

Applied.
