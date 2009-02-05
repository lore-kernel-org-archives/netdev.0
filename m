From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Thu, 5 Feb 2009 15:32:20 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0902051530520.3048@localhost.localdomain>
References: <b6a2187b0902050641h7943816ds26275a320e724440@mail.gmail.com> <20090205.152906.221253085.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jeff.chua.linux@gmail.com, herbert@gondor.apana.org.au,
	rjw@sisk.pl, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58768 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752998AbZBEXdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 18:33:03 -0500
In-Reply-To: <20090205.152906.221253085.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 5 Feb 2009, David Miller wrote:
> 
> Herbert, please help Jeff try to track down the cause of this.
> If we can't figure it out soon I'll have to revert.

Why is there even any discussion?

URG is broken as a concept, no sane/modern use case exists. It's totally 
uninteresting _except_ as a "legacy binary" issue, so

 - there's no point in trying to "improve" it.

 - even just a whiff of "breaks legacy app" just says "revert it".

No?

		Linus
