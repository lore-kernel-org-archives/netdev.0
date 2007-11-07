From: Jiri Olsa <olsajiri@gmail.com>
Subject: Re: [PATCH] net: Removing duplicit #includes
Date: Wed, 07 Nov 2007 10:06:18 +0100
Message-ID: <4731800A.6010502@gmail.com>
References: <47317771.406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:51495 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756039AbXKGJGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 04:06:24 -0500
Received: by nf-out-0910.google.com with SMTP id g13so1946146nfb
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2007 01:06:22 -0800 (PST)
In-Reply-To: <47317771.406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sorry, the patch is mangled, I will resend another 

Jiri Olsa wrote:
> Removing duplicit #includes for net/
> Signed-off-by: Jiri Olsa <olsajiri@gmail.com> ---
> net/core/dst.c                       |    1 -
> net/ieee80211/ieee80211_crypt_tkip.c |    1 -
> net/ieee80211/ieee80211_crypt_wep.c  |    1 -
> 3 files changed, 0 insertions(+), 3 deletions(-)
> 
> diff --git a/net/core/dst.c b/net/core/dst.c
> index 16958e6..03daead 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -18,7 +18,6 @@
> #include <linux/types.h>
> #include <net/net_namespace.h>
> 
> -#include <net/net_namespace.h>
> #include <net/dst.h>
> 
> /*
> diff --git a/net/ieee80211/ieee80211_crypt_tkip.c
> b/net/ieee80211/ieee80211_crypt_tkip.c
> index 4cce353..58b2261 100644
> --- a/net/ieee80211/ieee80211_crypt_tkip.c
> +++ b/net/ieee80211/ieee80211_crypt_tkip.c
> @@ -25,7 +25,6 @@
> #include <net/ieee80211.h>
> 
> #include <linux/crypto.h>
> -#include <linux/scatterlist.h>
> #include <linux/crc32.h>
> 
> MODULE_AUTHOR("Jouni Malinen");
> diff --git a/net/ieee80211/ieee80211_crypt_wep.c
> b/net/ieee80211/ieee80211_crypt_wep.c
> index 866fc04..3fa30c4 100644
> --- a/net/ieee80211/ieee80211_crypt_wep.c
> +++ b/net/ieee80211/ieee80211_crypt_wep.c
> @@ -22,7 +22,6 @@
> #include <net/ieee80211.h>
> 
> #include <linux/crypto.h>
> -#include <linux/scatterlist.h>
> #include <linux/crc32.h>
> 
> MODULE_AUTHOR("Jouni Malinen");
> 

