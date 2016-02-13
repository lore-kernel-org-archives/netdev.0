From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: fix memory leaks in ip_cmsg_send() callers
Date: Sat, 13 Feb 2016 05:59:13 -0500 (EST)
Message-ID: <20160213.055913.753295457600167686.davem@davemloft.net>
References: <CACT4Y+YMUc8j4_-oJfi0XmQebhaTZa2NTipSFY_ra38V-TAyXQ@mail.gmail.com>
	<1454594653.7627.290.camel@edumazet-glaptop2.roam.corp.google.com>
	<1454595808.7627.296.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48227 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293AbcBMK7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Feb 2016 05:59:16 -0500
In-Reply-To: <1454595808.7627.296.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 04 Feb 2016 06:23:28 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Dmitry reported memory leaks of IP options allocated in
> ip_cmsg_send() when/if this function returns an error.
> 
> Callers are responsible for the freeing.
> 
> Many thanks to Dmitry for the report and diagnostic.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
