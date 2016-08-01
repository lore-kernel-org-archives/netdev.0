From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: e1000: do not use uninitalized variable.
Date: Sun, 31 Jul 2016 20:45:23 -0700 (PDT)
Message-ID: <20160731.204523.1618478478722431612.davem@davemloft.net>
References: <1469957458-494-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xypron.glpk@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469957458-494-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Sun, 31 Jul 2016 11:30:58 +0200

> phy_data has to be set to zero to avoid undefined
> behavior.

In your opinion.

phy_data is only used in conditions where it has been initialized
in this function.

Therefore, please read the function carefully instead of just having
knee jerk reactions to whatever the compiler spits out.
