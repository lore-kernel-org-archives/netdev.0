From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: make sysctl_tcp_ecn namespace aware
Date: Sat, 05 Jan 2013 17:27:26 -0800
Message-ID: <1357435646.1678.5082.camel@edumazet-glaptop>
References: <20130105150130.GC4031@order.stressinduktion.org>
	 <20130105110005.2bf230eb@nehalam.linuxnetplumber.net>
	 <20130105190508.GE4031@order.stressinduktion.org>
	 <20130106011849.GA28545@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:37872 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754791Ab3AFB13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 20:27:29 -0500
Received: by mail-pa0-f50.google.com with SMTP id hz10so10017487pad.9
        for <netdev@vger.kernel.org>; Sat, 05 Jan 2013 17:27:29 -0800 (PST)
In-Reply-To: <20130106011849.GA28545@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-01-06 at 02:18 +0100, Hannes Frederic Sowa wrote:

> 
> I just verified that req->sk is indeed not initialized at that point. I
> had a kernel panic on the first syn packet. So I would propose to keep
> the patch as it is.
> 

Please pass the "struct net" pointer instead, so that the tcp_ecn
dereference is done only if really needed.

Naming a function parameter, or an automatic variable, sysctl_tcp_ecn is
not very nice.
