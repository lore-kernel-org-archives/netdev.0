From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 08/10] r8169:change function name of function
 "r8168dp_check_dash" to "r8168_check_dash"
Date: Tue, 30 Sep 2014 16:45:33 -0400 (EDT)
Message-ID: <20140930.164533.2014251085729375033.davem@davemloft.net>
References: <1412089230-10208-1-git-send-email-hau@realtek.com>
	<1412089230-10208-8-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: hau@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412089230-10208-8-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chun-Hao Lin <hau@realtek.com>
Date: Tue, 30 Sep 2014 23:00:28 +0800

> @@ -4364,7 +4364,7 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
>  	if ((tp->mac_version == RTL_GIGA_MAC_VER_27 ||
>  	     tp->mac_version == RTL_GIGA_MAC_VER_28 ||
>  	     tp->mac_version == RTL_GIGA_MAC_VER_31) &&
> -	    r8168dp_check_dash(tp)) {
> +	     r8168_check_dash(tp)) {

You are breaking the indentation here, "r8169_check_dash..." should start exactly
at the first column after the openning parenthesis of the if() statement.

So that's a TAB and four SPACE characters, not five SPACE characters.
