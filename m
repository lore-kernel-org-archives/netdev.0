From: David Miller <davem@davemloft.net>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Thu, 28 Aug 2008 12:42:51 -0700 (PDT)
Message-ID: <20080828.124251.149964287.davem@davemloft.net>
References: <21915755.1327801219904892242.JavaMail.root@ouachita>
	<48B6E7D0.5070307@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmalicki@metacarta.com, andi@firstfloor.org, johnpol@2ka.mipt.ru,
	dada1@cosmosbay.com, denys@visp.net.lb, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, juhlenko@akamai.com, sammy@sammy.net
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40842
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753498AbYH1Tm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 15:42:56 -0400
In-Reply-To: <48B6E7D0.5070307@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Thu, 28 Aug 2008 11:00:48 -0700

> Earlier in the thread mention was made of financial services types.
> If someone has knowledge of the (probably) arcane rules under which
> they must operate it would be great to hear more.  Does some entity
> like the SEC (Securities and Exchange Commission in the United
> States) mandate some sort of timestamp for when the trading request
> "arrives at the trading system" and do they define that "arriving at
> the trading system" means?

The issue is the ordering of processing the requests.

So if request A arrived on interface 1 before request B arrived on
interface 2, the trade described in A should be performed before the
one in B.

This is not "arcance" as you seem to suppose it might be, but rather
pretty clear fair handling or requests sent between trading desks.

