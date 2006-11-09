From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/6] [NET]: Rethink mark field in struct flowi
Date: Thu, 9 Nov 2006 14:34:03 +0100
Message-ID: <20061109133403.GD8693@postel.suug.ch>
References: <20061109112735.577771022@lsx.localdomain> <20061109113245.573179984@lsx.localdomain> <200611091423.02504.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:65233 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S965992AbWKINdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 08:33:42 -0500
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <200611091423.02504.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Eric Dumazet <dada1@cosmosbay.com> 2006-11-09 14:23
> I give a big NACK to this patch.
> 
> By moving fwmark outside of union, you basically touch more cache lines in 
> lookups. I have many machines doing XX.XXX of lookups per second, with long 
> chains, already using 10% of CPU. I am sure a lot of other machines would 
> suffer with this patch, especially machines with 32 bytes cache lines.
> 
> For IPV4 lookups, compare offset of fwmark before your patch and after.
> The size of ip6_u is so large that moving fwmark after nl_u union is not an 
> option. Many packets in flight on the Internet are still IPV4.

Would you be happy if mark is moved in front of the union after iif?
