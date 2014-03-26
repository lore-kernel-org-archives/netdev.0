From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 net 1/2] net: Allow modules to use is_skb_forwardable
Date: Wed, 26 Mar 2014 22:18:33 +0300
Message-ID: <53332809.4000404@cogentembedded.com>
References: <1395850490-27628-1-git-send-email-vyasevic@redhat.com> <1395850490-27628-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, shemminger@vyatta.com
To: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:55495 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbaCZSSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 14:18:36 -0400
Received: by mail-la0-f54.google.com with SMTP id mc6so1827103lab.13
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 11:18:35 -0700 (PDT)
In-Reply-To: <1395850490-27628-2-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/26/2014 07:14 PM, Vlad Yasevich wrote:

> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
[...]

> diff --git a/net/core/dev.c b/net/core/dev.c
> index b1b0c8d..a98f7fa 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1645,7 +1645,7 @@ static inline void net_timestamp_set(struct sk_buff *skb)
>   			__net_timestamp(SKB);		\
>   	}						\
>
> -static inline bool is_skb_forwardable(struct net_device *dev,
> +bool is_skb_forwardable(struct net_device *dev,
>   				      struct sk_buff *skb)

    Please re-indent the above line, so that it still starts under *struct*.

>   {
>   	unsigned int len;

WBR, Sergei
