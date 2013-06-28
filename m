From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Check the argument for listen(2)
Date: Fri, 28 Jun 2013 09:48:24 -0700
Message-ID: <1372438104.3301.290.camel@edumazet-glaptop>
References: <1372436076-61436-1-git-send-email-xiaosuo@gmail.com>
	 <1372436942.3301.286.camel@edumazet-glaptop>
	 <20130628163234.GA651@order.stressinduktion.org>
	 <20130628163458.GB651@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:65352 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754695Ab3F1QsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 12:48:16 -0400
Received: by mail-ee0-f48.google.com with SMTP id b47so1136066eek.7
        for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 09:48:15 -0700 (PDT)
In-Reply-To: <20130628163458.GB651@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-28 at 18:34 +0200, Hannes Frederic Sowa wrote:

> Nonsense, somaxconn would make more sense.
> 


If we keep u16, we could limit the sysctl (somaxconn,
tcp_max_syn_backlog) limits to 65535
