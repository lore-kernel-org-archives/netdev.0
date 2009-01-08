From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] IPV6 address management
Date: Thu, 08 Jan 2009 11:24:20 -0800 (PST)
Message-ID: <20090108.112420.102641584.davem@davemloft.net>
References: <20090108093430.0f966738@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57815
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760863AbZAHTYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 14:24:18 -0500
In-Reply-To: <20090108093430.0f966738@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 8 Jan 2009 09:34:30 -0800

> I notice that with IPV6 when interface is brought down, all addresses
> are removed. This looks like intentional behaviour but means the
> administrator (or daemon) must reinsert addresses. Since this is not
> what the users expect it does lead to confusion.
> 
> Maybe the kernel should do this?

After we've had this behavior for as long as we have, I doubt we can
safely change it.

I do agree it is unintuitive, and it also disagrees with ipv4 as you
already know.

There are several crucial areas where our behavior deviates between
ipv4 and ipv6, including this case.  And as more people start making
real use of ipv6 we will see these complaints pop up over and over
again from users.
