From: David Miller <davem@davemloft.net>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 19:55:04 -0500 (EST)
Message-ID: <20151119.195504.2050784646947745419.davem@davemloft.net>
References: <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
	<20151119.005318.838757439536205791.davem@davemloft.net>
	<CAKD1Yr0Es9JqdDi_05Kif=TyCSA+n7yDHUNr-ND-SD4j4p=D9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	edumazet@google.com, ek@google.com, maze@google.com,
	dtor@google.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52105 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161118AbbKTAzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 19:55:07 -0500
In-Reply-To: <CAKD1Yr0Es9JqdDi_05Kif=TyCSA+n7yDHUNr-ND-SD4j4p=D9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Fri, 20 Nov 2015 09:19:25 +0900

> In this case, userspace knows that that app's connections are now
> unusable because it configured an iptables rule to block them. The
> kernel doesn't really know until it the time comes to send a packet,
> and maybe not even then.

Netfilter could perform signalling on skb->sk when it drops packets.

Your example is actually a argument _for_ doing this in the kernel.

:-)
