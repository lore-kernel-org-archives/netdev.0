From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 02/10] r8169:add disable/enable RTL8168G pll
 function
Date: Tue, 30 Sep 2014 16:43:32 -0400 (EDT)
Message-ID: <20140930.164332.1854194776177723982.davem@davemloft.net>
References: <1412089230-10208-1-git-send-email-hau@realtek.com>
	<1412089230-10208-2-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: hau@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412089230-10208-2-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chun-Hao Lin <hau@realtek.com>
Date: Tue, 30 Sep 2014 23:00:22 +0800

> @@ -4399,8 +4400,10 @@ static void r8168_pll_power_up(struct rtl8169_private *tp)
>  		break;
>  	case RTL_GIGA_MAC_VER_40:
>  	case RTL_GIGA_MAC_VER_41:
> +		RTL_W8(PMCH, RTL_R8(PMCH) | 0xc0);
>  		rtl_w1w0_eri(tp, 0x1a8, ERIAR_MASK_1111, 0xfc000000,
>  			     0x00000000, ERIAR_EXGMAC);
> +
>  		break;

There is no reason to add an empty line before the break; statement.
