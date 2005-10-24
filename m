From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH]IPv6: fix refcnt of struct ip6_flowlabel
Date: Mon, 24 Oct 2005 16:35:33 -0200
Message-ID: <39e6f6c70510241135p18b018bo896b3565fa5ce87b@mail.gmail.com>
References: <435CCF7B.6030907@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751242AbVJXSff@vger.kernel.org>
To: =?ISO-2022-JP?Q?YOSHIFUJI_Hideaki_/_=1B=24B5HF=231QL=40=1B=28B?=
	<yoshfuji@linux-ipv6.org>, Yan Zheng <yanzheng@21cn.com>
In-Reply-To: <435CCF7B.6030907@21cn.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/24/05, Yan Zheng <yanzheng@21cn.com> wrote:
> Signed-off-by: Yan Zheng <yanzheng@21cn.com>
>
>
> Index: net/ipv6/ip6_flowlabel.c
> ===================================================================
> --- linux-2.6.14-rc5/net/ipv6/ip6_flowlabel.c   2005-10-22 10:31:13.000000000 +0800
> +++ linux/net/ipv6/ip6_flowlabel.c      2005-10-24 19:55:23.000000000 +0800
> @@ -483,7 +483,7 @@
>                                                 goto done;
>                                         }
>                                         fl1 = sfl->fl;
> -                                       atomic_inc(&fl->users);
> +                                       atomic_inc(&fl1->users);
>                                         break;

Looks OK to me, Yoshifuji-san, ACK?

- Arnaldo
