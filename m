From: Stanislav Yakovlev <stas.yakovlev@gmail.com>
Subject: Re: [PATCH 1/5] drivers/net/wireless/ipw2x00/ipw2100.c: introduce
 missing initialization
Date: Sun, 19 Aug 2012 13:36:49 +0400
Message-ID: <CA++WF2MmTe6WP6MQRV-v1VwkpcUrw4hU6yh79NdG-K4snzQkbg@mail.gmail.com>
References: <1345325159-7365-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345325159-7365-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Julia,

On 19 August 2012 01:25, Julia Lawall <Julia.Lawall@lip6.fr> wrote:
> -       ipw2100_get_ordinal(priv, IPW_ORD_STAT_ASSN_AP_BSSID, &bssid, &len);
> +       ret = ipw2100_get_ordinal(priv, IPW_ORD_STAT_ASSN_AP_BSSID, &bssid,
> +                                 &len);

This is correct, but this line has one more typo. It should be

-&bssid
+bssid

according to the bssid definition in the beginning of the function:

u8 bssid[ETH_ALEN];

Could you fix this as well?

Thanks!
Stanislav.
