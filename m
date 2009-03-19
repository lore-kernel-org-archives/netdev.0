From: David Miller <davem@davemloft.net>
Subject: Re: IPv6 address printf format specifier
Date: Wed, 18 Mar 2009 22:30:13 -0700 (PDT)
Message-ID: <20090318.223013.142429036.davem@davemloft.net>
References: <49BE889C.8080602@hp.com>
	<20090318.185826.221840814.davem@davemloft.net>
	<49C1AD56.5000608@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chuck.lever@oracle.com, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45363
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750779AbZCSFa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 01:30:27 -0400
In-Reply-To: <49C1AD56.5000608@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 18 Mar 2009 22:26:30 -0400

> There are multiple different forms of presenting addresses, all of
> which are valid and non of which will provide for sting equality.
> Regardless of how we represent our IPv6 addresses, there is a chance
> that it will cause interoperability issues and the only way to truly
> solve it is to change applications to compare addresses in their
> true numerical representation.

Or to, they themselves, canonicalize the text representation before
comparison.
