From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8169: add a new chip for RTL8411
Date: Wed, 10 Jul 2013 17:43:39 -0700 (PDT)
Message-ID: <20130710.174339.1202620552412048634.davem@davemloft.net>
References: <1373274541-1095-1-git-send-email-hayeswang@realtek.com>
	<20130709.125305.1668056299963467935.davem@davemloft.net>
	<20130709230015.GA6843@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130709230015.GA6843@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 10 Jul 2013 01:00:16 +0200

> David Miller <davem@davemloft.net> :
> [...]
>> Francois, please review.
> 
> The style is consistent with the driver.
> 
> The commit message may state that this 8411 chipset does not require
> any special action in rtl_link_chg_patch (whence differing from the
> previous "F" 8411).
> 
> Most of the code shared by rtl_hw_start_8168g_2 and rtl_hw_start_8411_2
> is already factored out. There is not much to win here.
> 
> The new RTL_GIGA_MAC_VER_XY id is added in the required places.
> 
> It builds.
> 
> It's fine.

Thanks for reviewing, applied.
