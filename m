From: David Miller <davem@davemloft.net>
Subject: Re: suspicious logic in tcp_make_synack()
Date: Mon, 27 Oct 2008 11:30:56 -0700 (PDT)
Message-ID: <20081027.113056.16263457.davem@davemloft.net>
References: <20081026174147.GB27584@Chamillionaire.breakpoint.cc>
	<20081026.231102.214077979.davem@davemloft.net>
	<396556a20810270851x18ad55c6sd690457af6616224@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43443
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751831AbYJ0SbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 14:31:18 -0400
In-Reply-To: <396556a20810270851x18ad55c6sd690457af6616224@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Mon, 27 Oct 2008 08:51:19 -0700

> Although that commit was born of an attempt to save some people from
> some of the pitfalls of modifying the previous code it clearly wasn't
> something that I should have attempted. The cost of newbies touching
> code in that area is too great both in tickling bugs in other systems
> (with option ordering) and in stupid omissions like this.

Adam, as I said, you and I share this burdon :-)  I should have
reviewed your changes more thoroughly, and for this change that is
true no matter who actually wrote it.

> If nothing else, suspicion of that commit has probably been raised
> to such a level that competent folks have checked it all over now.

Yes, I think we've fixed up all the issues by now.
