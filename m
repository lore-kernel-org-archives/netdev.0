From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Simplify skb_tx_hash()
Date: Tue, 17 Feb 2009 23:41:58 -0800 (PST)
Message-ID: <20090217.234158.156650176.davem@davemloft.net>
References: <20090218053211.16619.33544.sendpatchset@localhost.localdomain>
	<20090217.225355.184526778.davem@davemloft.net>
	<OF35128638.A15DA997-ON65257561.00265DD2-65257561.0028F5BC@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42968
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751670AbZBRHmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 02:42:14 -0500
In-Reply-To: <OF35128638.A15DA997-ON65257561.00265DD2-65257561.0028F5BC@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Wed, 18 Feb 2009 12:57:23 +0530

> > David Miller <davem@davemloft.net>
> > A patch like this needs justification, so in your commit
> > logs you shouldn't just list out mechanically what your
> > patch is doing, but rather explain "why".
> 
> Please let me know if I should give a better text for justification?

Even after reading all of this I still don't understand why
you're making the change.

Is it to eliminate the comparison every packet in skb_tx_hash()?

If so, say that in the commit message so nobody has to
guess.  Saying just "simplify" doesn't express that at all.

