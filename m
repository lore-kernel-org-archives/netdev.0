From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [PATCH net-next] 8139too: Add 64bit statistics
Date: Mon, 5 Mar 2012 22:07:33 +0800
Message-ID: <20120305140731.GA3188@Laptop-Junchang>
References: <20120305113353.GA12969@Spy32>
 <1330954326.2474.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, greearb@candelatech.com, adobriyan@gmail.com,
	jasowang@redhat.com, joe@perches.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:46104 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932388Ab2CEOFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 09:05:16 -0500
Received: by dadp12 with SMTP id p12so5144374dad.11
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 06:05:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1330954326.2474.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
>Maybe its time to export netdev_stats_to_stats64() after all, to avoid
>all this duplicate code.

Yes, I noticed this duplicate code in both 8139too.c and r8169.c, and
netdev_stats_to_stats64 was not exported.

>
>I'll submit a patch.
>
>Could you repost this after netdev_stats_to_stats64() being available to
>drivers ?
>

Sure, I'll resubmit it based on your patch. Thanks.


--Junchang
