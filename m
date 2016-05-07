From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net] macvtap: segmented packet is consumed
Date: Sat, 7 May 2016 10:44:01 +0300
Message-ID: <20160507104401.000731dd@halley>
References: <1462539501.13075.29.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38617 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbcEGHoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 03:44:12 -0400
Received: by mail-wm0-f49.google.com with SMTP id g17so108938065wme.1
        for <netdev@vger.kernel.org>; Sat, 07 May 2016 00:44:11 -0700 (PDT)
In-Reply-To: <1462539501.13075.29.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 06 May 2016 05:58:21 -0700 Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> If GSO packet is segmented and its segments are properly queued,
> we call consume_skb() instead of kfree_skb() to be drop monitor
> friendly.
> 
> Fixes: 3e4f8b7873709 ("macvtap: Perform GSO on forwarding path.")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Vlad Yasevich <vyasevic@redhat.com>

Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
