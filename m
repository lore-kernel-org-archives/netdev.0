From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@wide.ad.jp>
Subject: Re: [patch-kj] net/econet/af_econet.c fix warning xyz never used
Date: Tue, 22 Jun 2004 02:51:38 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622.025138.33683810.yoshfuji@wide.ad.jp>
References: <20040621170904.GD1545@sputnik.stro.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: janitor@sternwelten.at
In-Reply-To: <20040621170904.GD1545@sputnik.stro.at>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040621170904.GD1545@sputnik.stro.at> (at Mon, 21 Jun 2004 19:09:04 +0200), maximilian attems <janitor@sternwelten.at> says:

> From: <WHarms@bfs.de>(Walter Harms)
> moving the define a bit higher removes two useless warnings.
:
> Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
:
>  	unsigned char port, cb;
> +#ifdef CONFIG_ECONET_NATIVE
>  	struct sk_buff *skb;
>  	struct ec_cb *eb;
> -#ifdef CONFIG_ECONET_NATIVE
>  	unsigned short proto = 0;

Already fixed in current bk tree. Thanks.

--yoshfuji
