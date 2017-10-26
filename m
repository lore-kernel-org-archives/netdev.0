From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] net: bcmgenet: start/stop sequence
 refinement
Date: Thu, 26 Oct 2017 10:15:19 +0900 (KST)
Message-ID: <20171026.101519.1832588976191061738.davem@davemloft.net>
References: <20171025220419.24951-1-opendmb@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: opendmb@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171025220419.24951-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Doug Berger <opendmb@gmail.com>
Date: Wed, 25 Oct 2017 15:04:10 -0700

> This commit set is the result of an investigation into an issue that
> occurred when bringing the interface up and down repeatedly with an
> external 100BASE-T PHY. In some cases the MAC would experience mass
> receive packet duplication that could in rare cases lead to a stall
> from overflow.  The fix for this is contained in the third commit.
> 
> The first 3 commits represent bug fixes that should be applied to the
> net repository and are candidates for backporting to stable releases.
> The remaining commits are enhancements which is why the set is being
> submitted to net-next but they are implemented on top of the fixes.
> 
> The first fix is provided as justification for why the set isn't
> split between a net submission and a net-next submission.

Series applied.

Thanks for fixing up the merge error, I really appreciate that!
