From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 02/12] net: dsa: add Broadcom tag hook
Date: Wed, 06 Aug 2014 16:25:48 +0400
Message-ID: <53E21ECC.9000705@cogentembedded.com>
References: <1407277906-19989-1-git-send-email-f.fainelli@gmail.com> <1407277906-19989-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linville@tuxdriver.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:33259 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752363AbaHFMZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 08:25:51 -0400
Received: by mail-la0-f49.google.com with SMTP id hz20so1828081lab.8
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 05:25:50 -0700 (PDT)
In-Reply-To: <1407277906-19989-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/6/2014 2:31 AM, Florian Fainelli wrote:

> Register a fake Ethertype for the Broadcom tag to allow us to hook into
> a given Ethernet device receive path and parse this Broadcom tag.

> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
[...]

> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index 6efce384451e..0ada9c814ff9 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -203,4 +203,9 @@ static inline bool dsa_uses_trailer_tags(struct dsa_switch_tree *dst)
>   	return !!(dst->tag_protocol == htons(ETH_P_TRAILER));
>   }
>
> +static inline bool dsa_uses_brcm_tags(struct dsa_switch_tree *dst)
> +{
> +	return !!(dst->tag_protocol == htons(ETH_P_BRCMTAG));

    Er, !! doesn't seem needed here.

> +}
> +
>   #endif

WBR, Sergei
