From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] ipv4: don't disable interface if last ipv4 address
 is removed
Date: Wed, 22 Jan 2014 17:52:34 -0800 (PST)
Message-ID: <20140122.175234.1504624022995273271.davem@davemloft.net>
References: <cover.1390304505.git.popovich_sergei@mail.ru>
	<cover.1390304505.git.popovich_sergei@mail.ru>
	<2748ead3b814852075f954ea157fe5d7288531e2.1390304505.git.popovich_sergei@mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: popovich_sergei@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52600 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbaAWBwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 20:52:36 -0500
In-Reply-To: <2748ead3b814852075f954ea157fe5d7288531e2.1390304505.git.popovich_sergei@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergey Popovich <popovich_sergei@mail.ru>
Date: Tue, 21 Jan 2014 13:48:48 +0200

> Since
> 
>   commit 876fd05ddbae03166e7037fca957b55bb3be6594
>   Author: Hannes Frederic Sowa <>
>   Date:   Mon Jun 24 00:22:20 2013 +0200
> 
>     ipv6: don't disable interface if last ipv6 address is removed
> 
> we have disabled this behavior for IPv6. Adjust behavior for IPv4.

I do not agree with this change.

IPV4 is a lot different from ipv6, for example ipv4 lacks things like
temporary address assignments and other notifications that links listen
to even if they don't have explicit static addressed assigned.

The ipv4 behavior also has two decades of precedence, and I think you'll
have a very hard time convincing me that nobody depends upon it.

So I'm not applying this patch, sorry.
