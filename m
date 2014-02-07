From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netpoll: fix netconsole IPv6 setup
Date: Thu, 06 Feb 2014 22:29:41 -0800 (PST)
Message-ID: <20140206.222941.133253353479069351.davem@davemloft.net>
References: <1391708052-11188-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40364 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbaBGG3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 01:29:42 -0500
In-Reply-To: <1391708052-11188-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Thu,  6 Feb 2014 18:34:12 +0100

> Currently, to make netconsole start over IPv6, the source address
> needs to be specified. Without a source address, netpoll_parse_options
> assumes we're setting up over IPv4 and the destination IPv6 address is
> rejected.
> 
> Check if the IP version has been forced by a source address before
> checking for a version mismatch when parsing the destination address.
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied and queued up for -stable.
