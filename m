From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: replacing a rt6_info needs to purge possible
 propagated rt6_infos too
Date: Tue, 27 Jan 2015 00:23:03 -0800 (PST)
Message-ID: <20150127.002303.21930811137608230.davem@davemloft.net>
References: <131075b1c8770c414675094c292d394316e8cd17.1422281427.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkundrak@v3.sk
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48374 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751661AbbA0IXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 03:23:04 -0500
In-Reply-To: <131075b1c8770c414675094c292d394316e8cd17.1422281427.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 26 Jan 2015 15:11:17 +0100

> Lubomir Rintel reported that during replacing a route the interface
> reference counter isn't correctly decremented.
 ...
> During replacement of a rt6_info we must walk all parent nodes and check
> if the to be replaced rt6_info got propagated. If so, replace it with
> an alive one.
> 
> Reported-by: Lubomir Rintel <lkundrak@v3.sk>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
