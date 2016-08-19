From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: thunderx: Fix OOPs with ethtool --register-dump
Date: Thu, 18 Aug 2016 21:16:55 -0700 (PDT)
Message-ID: <20160818.211655.897588198741403986.davem@davemloft.net>
References: <1471375697-1878-1-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        sgoutham@cavium.com, rric@kernel.org,
        linux-arm-kernel@lists.infradead.org, david.daney@cavium.com,
        stable@vger.kernel.org
To: ddaney.cavm@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471375697-1878-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney.cavm@gmail.com>
Date: Tue, 16 Aug 2016 12:28:17 -0700

> From: David Daney <david.daney@cavium.com>
> 
> The ethtool_ops .get_regs function attempts to read the nonexistent
> register NIC_QSET_SQ_0_7_CNM_CHG, which produces a "bus error" type
> OOPs.
> 
> Fix by not attempting to read, and removing the definition of,
> NIC_QSET_SQ_0_7_CNM_CHG.  A zero is written into the register dump to
> keep the layout unchanged.
> 
> Signed-off-by: David Daney <david.daney@cavium.com>

Applied.
