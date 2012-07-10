From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 6/6] r8169: support RTL8168G
Date: Tue, 10 Jul 2012 11:00:45 +0200
Message-ID: <20120710090045.GA32387@electric-eye.fr.zoreil.com>
References: <1341898590-1253-1-git-send-email-hayeswang@realtek.com> <1341904369-5277-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1341904369-5277-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(you should include a Signed-off-by)

Hayes Wang <hayeswang@realtek.com> :
> 1. Remove rtl_ocpdr_cond. No waiting is needed for mac_ocp_{write / read}.

Nit: it would not hurt to do a better job than me and save some commit noise
getting these things right before they pollute the history. :o)

> 2. Set ocp_base to OCP_STD_PHY_BASE after rtl8168g_1_hw_phy_config.

Can't it be stuffed into the firmware ?

The code does not explicitely switch from the PHY access context to
the extra OCP registers one and anything else in rtl8168g_1_hw_phy_config
seems to directly use the addresses it needs. So I'd expect the current
imbalance to come from the firmware, where it would make as much sense to
fix it
-> no imbalance after the firmware is applied
-> no useless instruction if the firmware is not used

-- 
Ueimor
