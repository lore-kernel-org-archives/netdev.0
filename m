From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 17:46:32 -0700 (PDT)
Message-ID: <20071005.174632.101859385.davem@davemloft.net>
References: <20071005084317.52ee7efe@freepuppy.rosehill>
	<20071005.170428.68050176.davem@davemloft.net>
	<20071005172801.7f657e81@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59946
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755680AbXJFAqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 20:46:33 -0400
In-Reply-To: <20071005172801.7f657e81@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 5 Oct 2007 17:28:01 -0700

> On Fri, 05 Oct 2007 17:04:28 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Stephen Hemminger <shemminger@linux-foundation.org>
> > Date: Fri, 5 Oct 2007 08:43:17 -0700
> > 
> > > drivers/net/niu.c:203:2: error: bad constant expression
> > > drivers/net/niu.c:203:2: error: cannot size expression
> > > drivers/net/niu.c:4214:2: error: bad constant expression
> > > drivers/net/niu.c:4214:2: error: cannot size expression
> > 
> > I can't figure out what sparse doesn't like here.
> 
> Sparse doesn't like dynamically sized arrays, which is what BUILD_BUG_ON()
> expands into.  Not sure why it is hostile to dynamic arrays,
> probably just a Linus (or Viro) taste thing.

Ok, thanks for tracking it down Stephen.
