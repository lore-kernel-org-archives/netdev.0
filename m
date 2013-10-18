From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net REPOST 0/3] UFO fixes
Date: Fri, 18 Oct 2013 19:15:24 +0200
Message-ID: <20131018171524.GC1491@minipsycho.orion>
References: <1382116431-28758-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	hannes@stressinduktion.org, jdmason@kudzu.us,
	yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:58563 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756234Ab3JRRP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 13:15:27 -0400
Received: by mail-ea0-f176.google.com with SMTP id q16so2174631ead.35
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 10:15:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1382116431-28758-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes, sorry for messed up email address :/

Fri, Oct 18, 2013 at 07:13:48PM CEST, jiri@resnulli.us wrote:
>Couple of patches fixing UFO functionality in different situations.
>
>Jiri Pirko (3):
>  udp6: respect IPV6_DONTFRAG sockopt in case there are pending frames
>  ip6_output: do skb ufo init for peeked non ufo skb as well
>  ip_output: do skb ufo init for peeked non ufo skb as well
>
> net/ipv4/ip_output.c  | 14 +++++++++-----
> net/ipv6/ip6_output.c | 26 ++++++++++++++------------
> net/ipv6/udp.c        |  5 ++---
> 3 files changed, 25 insertions(+), 20 deletions(-)
>
>-- 
>1.8.3.1
>
