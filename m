From: David Miller <davem@davemloft.net>
Subject: Re: oh crap...
Date: Wed, 29 Oct 2008 11:31:42 -0700 (PDT)
Message-ID: <20081029.113142.135680097.davem@davemloft.net>
References: <1225294760.5269.301.camel@localhost>
	<1225301082.5688.24.camel@brick>
	<1225304214.5269.339.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: harvey.harrison@gmail.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43441
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753111AbYJ2ScI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 14:32:08 -0400
In-Reply-To: <1225304214.5269.339.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 29 Oct 2008 11:16:54 -0700

> On Wed, 2008-10-29 at 10:24 -0700, Harvey Harrison wrote:
> > Putting a modifier after the format specifier seems a little strange to me.
> 
> Harvey, please remember the whole %p<foo> concept is based on
> modifier after format specifier.

I don't think there is any such strict rule, or even that we'd
want to enforce that.

There is nothing wrong with saying something like %pI6 where
the "I" signifies "internet address in 'natural' form" and
"6" is the 'modifier' which you love so much which means
"oh btw, it's ipv6"
