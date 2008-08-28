From: David Miller <davem@davemloft.net>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Thu, 28 Aug 2008 13:32:23 -0700 (PDT)
Message-ID: <20080828.133223.119110675.davem@davemloft.net>
References: <48B6E7D0.5070307@hp.com>
	<20080828.124251.149964287.davem@davemloft.net>
	<48B70AAA.7010504@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmalicki@metacarta.com, andi@firstfloor.org, johnpol@2ka.mipt.ru,
	dada1@cosmosbay.com, denys@visp.net.lb, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, juhlenko@akamai.com, sammy@sammy.net
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39594
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755172AbYH1Uc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 16:32:27 -0400
In-Reply-To: <48B70AAA.7010504@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Thu, 28 Aug 2008 13:29:30 -0700

> Has the request "hit the trading system" when it hits the NIC, or
> when it hits the application executing the trade?  If the SEC calls
> for when it hits the NIC, then none of what is done today is really
> accurate/correct and one would need to start using NIC HW
> timestamps, synchronized with the host and the other NICs in the
> system no?

The SEC isn't mandating anything here, stop framing it that way :-)

People simply won't trade with a firm if they find out that trades
there are executed out of order.

They are simply trying to make things as fair as possible.
