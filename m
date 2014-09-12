From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/phy: micrel: Disable asymmetric pause for
 KSZ9031
Date: Fri, 12 Sep 2014 18:18:20 -0400 (EDT)
Message-ID: <20140912.181820.1440041146938289489.davem@davemloft.net>
References: <5411ECE9.8050600@gmail.com>
	<1410525637-849-1-git-send-email-mike.looijmans@topic.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mike.looijmans@topic.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410525637-849-1-git-send-email-mike.looijmans@topic.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mike Looijmans <mike.looijmans@topic.nl>
Date: Fri, 12 Sep 2014 14:40:37 +0200

> The KSZ9031 appears to suffer from the same hardware bug as described
> for the KSZ9021 in commit 32fcafbcd1c9f6c7013016a22a5369b4acb93577
> ("net/phy: micrel: Disable asymmetric pause for KSZ9021")
> you have to unplug the cable and plug it back to get it to work.
> 
> Remove the SUPPORTED_Asym_Pause flag for the KSZ9031 to fix this.
> 
> Signed-off-by: Mike Looijmans <mike.looijmans@topic.nl>

This patch does not apply cleanly to the net tree, please respin.
