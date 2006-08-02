From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] IPv6: only set err in rawv6_bind() when necessary
Date: Wed, 02 Aug 2006 12:04:18 -0400
Message-ID: <44D0CD02.1060109@hp.com>
References: <44CF89FB.2060208@hp.com> <20060801.150352.104034113.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:24032 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S932081AbWHBQEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 12:04:22 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060801.150352.104034113.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Every other path going from this location in rawv6_bind()
> will clear err to zero, so your patch also doesn't fix any
> bug.

I knew it didn't fix a bug, I just hadn't noticed the C idiom you 
pointed-out until I knew to look for it.  rawv6_bind() even does this, duh.

-Brian
