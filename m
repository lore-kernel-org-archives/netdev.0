From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next 1/2] r8152: add CONFIG_RTL8152_EARLY_AGG_SUPER
Date: Wed, 12 Mar 2014 14:40:17 +0100
Message-ID: <87txb3lem6.fsf@nemi.mork.no>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
	<1394526259-5513-2-git-send-email-hayeswang@realtek.com>
	<1394628023-12713-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <nic_swsd@realtek.com>,
	<linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394628023-12713-1-git-send-email-hayeswang@realtek.com> (Hayes
	Wang's message of "Wed, 12 Mar 2014 20:39:58 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> writes:

> +	config RTL8152_EARLY_AGG_SUPER
> +		hex "rx early agg parameter for super speed"
> +		default 0x0e832981
> +		help
> +		  This is the rx early agg parameter for USB super speed.
> +
> +	endmenu

How do I as an end user know how to adjust this magic(?) value?  Having
a config setting like this without further documentation seems
completely pointless. Anyone with enough knowledge about the driver and
devices will be perfectly capable of editing the driver source anyway.



Bj=C3=B8rn
