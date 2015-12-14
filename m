From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] netlink: fix boolean evaluation on bound
Date: Mon, 14 Dec 2015 09:50:11 -0800
Message-ID: <1450115411.8474.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1450112125-29848-1-git-send-email-hannes@stressinduktion.org>
	 <20151214170642.GA4180@gondor.apana.org.au>
	 <566EFBF0.5020604@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36791 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753182AbbLNRuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 12:50:14 -0500
Received: by pacdm15 with SMTP id dm15so107030300pac.3
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 09:50:13 -0800 (PST)
In-Reply-To: <566EFBF0.5020604@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-12-14 at 18:27 +0100, Hannes Frederic Sowa wrote:

> Otherwise I would recommend adding a "!!" to express that we actually
> want bound set based on the portid value?

Note that compiler already does the !! thing, when you store an integer
into a bool var.

So it definitely is a matter of taste and code readability.
