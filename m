From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: Set sk_txhash from a random number
Date: Wed, 29 Jul 2015 11:29:06 +0200
Message-ID: <1438162146.20182.74.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1438124526-2129341-1-git-send-email-tom@herbertland.com>
	 <1438124526-2129341-2-git-send-email-tom@herbertland.com>
	 <20150729091333.GB13113@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org, kernel-team@fb.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:35918 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbbG2J3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 05:29:10 -0400
Received: by wicgb10 with SMTP id gb10so191564788wic.1
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 02:29:09 -0700 (PDT)
In-Reply-To: <20150729091333.GB13113@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-07-29 at 11:13 +0200, Thomas Graf wrote:
> On 07/28/15 at 04:02pm, Tom Herbert wrote:
> > This patch creates sk_set_txhash and eliminates protocol specific
> > inet_set_txhash and ip6_set_txhash. sk_set_txhash simply sets a
> > random number instead of performing flow dissection. sk_set_txash
> > is also allowed to be called multiple times for the same socket,
> > we'll need this when redoing the hash for negative routing advice.
> > 
> > Signed-off-by: Tom Herbert <tom@herbertland.com>
> 
> Doesn't this break TX hashing with SO_REUSEPORT?


AFAIK nothing uses sk_txhash yet.
