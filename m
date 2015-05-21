From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 1/4] net: skbuff: add skb_append_pagefrags
 and use it
Date: Thu, 21 May 2015 07:10:45 -0700
Message-ID: <1432217445.4060.92.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1432200343.git.hannes@stressinduktion.org>
	 <255dfe7cbcbeb3f6fad7d4cf567625ae201d8eb3.1432200344.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, cwang@twopensource.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:38137 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755900AbbEUOKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 10:10:47 -0400
Received: by igcau1 with SMTP id au1so9401356igc.1
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 07:10:46 -0700 (PDT)
In-Reply-To: <255dfe7cbcbeb3f6fad7d4cf567625ae201d8eb3.1432200344.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-21 at 11:39 +0200, Hannes Frederic Sowa wrote:
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> v2:
> * remove now unused variable i in ip_append_page (thanks, Cong!)
> * switched to EXPORT_SYMBOL_GPL for skb_append_pagefrags
> 
>  include/linux/skbuff.h |  3 +++
>  net/core/skbuff.c      | 18 ++++++++++++++++++
>  net/ipv4/ip_output.c   | 15 ++++-----------
>  3 files changed, 25 insertions(+), 11 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
