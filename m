From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v2] act_mirred: don't clone skb when skb isn't shared
Date: Sat, 05 Jun 2010 10:49:05 -0400
Message-ID: <1275749345.3490.88.camel@bigi>
References: <1275741553-21463-1-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:63625 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756075Ab0FEOtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 10:49:08 -0400
Received: by vws5 with SMTP id 5so1094095vws.19
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 07:49:07 -0700 (PDT)
In-Reply-To: <1275741553-21463-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-06-05 at 20:39 +0800, Changli Gao wrote:

> +	if ((action == TC_ACT_SHOT || action == TC_ACT_STOLEN ||

I am not so sure about SHOT; the other two are fine.
 
> -	skb2 = skb_act_clone(skb, GFP_ATOMIC);
> +	at = G_TC_AT(skb->tc_verd);

Was there any need to move above line?

> +	skb2 = skb_act_clone(skb, GFP_ATOMIC, m->tcf_action);


> -	skb2->dev = dev;

Or this one?

>  	skb2->skb_iif = skb->dev->ifindex;
> +	skb2->dev = dev;


cheers,
jamal

