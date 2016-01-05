From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH 1/1] net/ipv6: add sysctl option accept_ra_min_hop_limit
Date: Tue, 5 Jan 2016 19:17:26 +0900
Message-ID: <568B9836.1000202@miraclelinux.com>
References: <1451896664-14271-1-git-send-email-machida.yuki@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	Hangbin Liu <liuhangbin@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"YOSHIFUJI Hideaki (USAGI Project)" <yoshfuji@linux-ipv6.org>
To: Yuki Machida <machida.yuki@jp.fujitsu.com>, netdev@vger.kernel.org,
	=?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kv5ZCJ6Jek6Iux5piO?=
	<hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34142 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590AbcAEKR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 05:17:29 -0500
Received: by mail-pa0-f42.google.com with SMTP id uo6so193707878pac.1
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 02:17:29 -0800 (PST)
In-Reply-To: <1451896664-14271-1-git-send-email-machida.yuki@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Machida-san.

Yuki Machida wrote:
> Please apply the following patch to v4.1.x.
> 
> By ommit 6fd99094de2b ("ipv6: Don't reduce hop limit for an interface")

s/ommit/commit/

Futher comment below.

:
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> Acked-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  Documentation/networking/ip-sysctl.txt |  8 ++++++++
>  include/linux/ipv6.h                   |  1 +
>  include/uapi/linux/ipv6.h              |  1 +
>  net/ipv6/addrconf.c                    | 10 ++++++++++
>  net/ipv6/ndisc.c                       | 16 +++++++---------
>  5 files changed, 27 insertions(+), 9 deletions(-)
> 
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index 071fb18..07fad3d 100644
:
> --- a/include/uapi/linux/ipv6.h
> +++ b/include/uapi/linux/ipv6.h
> @@ -171,6 +171,7 @@ enum {
>  	DEVCONF_USE_OPTIMISTIC,
>  	DEVCONF_ACCEPT_RA_MTU,
>  	DEVCONF_STABLE_SECRET,

You have to add a hole for DEVCONF_USE_OIF_ADDRS_ONLY.

--yoshfuji

> +	DEVCONF_ACCEPT_RA_MIN_HOP_LIMIT,
>  	DEVCONF_MAX
>  };
>  

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
