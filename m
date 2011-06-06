From: Reinhard Max <max@suse.de>
Subject: Re: Bad behaviour when unintentionally mixing ipv4 and ipv6
 addresses
Date: Mon, 6 Jun 2011 15:47:30 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1106061538210.13876@nitsch.suse.de>
References: <20110525155918.GA27869@suse.de> <20110601.210359.2079286191194442010.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: meissner@suse.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:44026 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751226Ab1FFNrc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2011 09:47:32 -0400
In-Reply-To: <20110601.210359.2079286191194442010.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 1 Jun 2011 at 21:03, David Miller wrote:

> Since we haven't been validating the sin_family field for 18+ years, 
> the chance to break some applications is very real.
>
> But I think it's more important to fix this (and force any broken 
> apps to set sin_family correctly).  So I will apply this, thanks.

I think a corresponding check should also go into inet6_bind() in 
net/ipv6/af_inet6.c .


cu
 	Reinhard
