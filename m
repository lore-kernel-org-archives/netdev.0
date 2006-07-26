From: Patrick McHardy <kaber@trash.net>
Subject: Re: BUGs in skb_checksum_help() and skb_gso_segment() in 2.6.18-rc2
Date: Wed, 26 Jul 2006 05:38:07 +0200
Message-ID: <44C6E39F.8010602@trash.net>
References: <E1G5ZBx-00084U-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, zdzichu@irc.pl,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54520 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932512AbWGZDjp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 23:39:45 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1G5ZBx-00084U-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> 
>>It is not a bug, but remind to update nat helper function.
> 
> 
> Yes, I need to add CHECKSUM_COMPLETE vs. CHECKSUM_PARTIAL first so that
> we actually know which is which in NAT.


I have a patch which changes netfilter to do incremental checksumming.
The hook number is passed to all functions doing this so they know
how to update the checksum. Could you explain how
CHECKSUM_COMPLETE/CHECKSUM_PARTIAL are going to be used? I assume
they're meant to avoid passing hook numbers around everywhere?

