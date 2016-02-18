From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net] r8169:fix "rtl_counters_cond == 1 (loop: 1000,
 delay: 10)" log spam.
Date: Thu, 18 Feb 2016 21:35:16 +0100
Message-ID: <20160218203516.GA18173@electric-eye.fr.zoreil.com>
References: <1455807427-3177-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: Chunhao Lin <hau@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1455807427-3177-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chunhao Lin <hau@realtek.com> :
[...]
> I add checking driver's pm runtime status in rtl8169_get_stats64() to fix
> this issue.

Would you consider taking the device out of suspended mode during
rtl8169_get_stats64 to prevent outdated stats ?

-- 
Ueimor
