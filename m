From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [PATCH] Prevent reading uninitialized memory with socket
 filters
Date: Wed, 10 Nov 2010 08:19:26 -0500
Message-ID: <1289395166.7380.69.camel@dan>
References: <1289341724.7380.13.camel@dan>
	 <20101109.212838.193698340.davem@davemloft.net>
	 <1289387567.7380.63.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org, security@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:61128 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755691Ab0KJNT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 08:19:28 -0500
In-Reply-To: <1289387567.7380.63.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For reasons I don't understand, this code seems to cause some people's
machines to lock up:

BUG: soft lockup - CPU#0 stuck for 10s! [dz:11844]

I haven't been able to reproduce this myself.  Very strange.  I'll send
a stack trace if I can reproduce.

-Dan

On Wed, 2010-11-10 at 06:12 -0500, Dan Rosenberg wrote:
> > 
> > Prove it.
> 
> I hope this was a joke.  In either case, my reply is a joke:
> 
> http://lists.grok.org.uk/pipermail/full-disclosure/2010-November/077321.html


