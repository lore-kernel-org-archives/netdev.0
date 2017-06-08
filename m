From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] drivers: net: add const to mii_phy_ops structures
Date: Thu, 08 Jun 2017 15:33:01 -0400 (EDT)
Message-ID: <20170608.153301.772657076797049260.davem@davemloft.net>
References: <1496901658-6476-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: bhumirks@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496901658-6476-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Thu,  8 Jun 2017 11:30:56 +0530

> The object references of mii_phy_ops structures are only stored
> in the ops field of a mii_phy_def structure. This ops field is of type
> const. So, mii_phy_ops structures having similar properties can be
> declared as const.

Series applied, thanks.
