From: David Miller <davem@davemloft.net>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Thu, 05 Feb 2009 15:38:01 -0800 (PST)
Message-ID: <20090205.153801.131216873.davem@davemloft.net>
References: <b6a2187b0902050641h7943816ds26275a320e724440@mail.gmail.com>
	<20090205.152906.221253085.davem@davemloft.net>
	<alpine.LFD.2.00.0902051530520.3048@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff.chua.linux@gmail.com, herbert@gondor.apana.org.au,
	rjw@sisk.pl, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42196
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752998AbZBEXiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 18:38:05 -0500
In-Reply-To: <alpine.LFD.2.00.0902051530520.3048@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 5 Feb 2009 15:32:20 -0800 (PST)

> On Thu, 5 Feb 2009, David Miller wrote:
> > 
> > Herbert, please help Jeff try to track down the cause of this.
> > If we can't figure it out soon I'll have to revert.
> 
> Why is there even any discussion?
> 
> URG is broken as a concept, no sane/modern use case exists. It's totally 
> uninteresting _except_ as a "legacy binary" issue, so
> 
>  - there's no point in trying to "improve" it.
> 
>  - even just a whiff of "breaks legacy app" just says "revert it".
> 
> No?

Sure, and we can put the change back in if we ever figure out what the
problem was.

This change is in 2.6.28 too, so I'll revert and queue the revert up
for -stable as well.
