From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH ethtool 2/3] ethtool: Add rx_copybreak support
Date: Sun, 5 Oct 2014 10:54:11 +0300
Message-ID: <5430F923.9050005@mellanox.com>
References: <1410602207-9084-1-git-send-email-_govind@gmx.com> <1410602207-9084-3-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <ssujith@cisco.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
To: Govindarajulu Varadarajan <_govind@gmx.com>, <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:42846 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750907AbaJEHyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 03:54:20 -0400
In-Reply-To: <1410602207-9084-3-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/13/2014 12:56 PM, Govindarajulu Varadarajan wrote:
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> ---

[...]

>  	  "		[ rx-jumbo N ]\n"
>  	  "		[ tx N ]\n" },
> +	{ "-b|--show-rx_copybreak", 1, do_grx_copybreak, "Show rx_copybreak value" },
> +	{ "-B|--set-rx_copybreak", 1, do_srx_copybreak, "Set rx_copybreak value",
> +	  "		N\n" },
>  	{ "-k|--show-features|--show-offload", 1, do_gfeatures,

Hi,

Since a get/set for TX copybreak will be also is needed, please change
the user command to something like "-b rx NNN", and when I will add tx
copybreak support, I will add "-b tx NNN".

Thanks,
amir
