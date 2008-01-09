From: David Miller <davem@davemloft.net>
Subject: Re: Linux IPv6 DAD not full conform to RFC 4862 ?
Date: Wed, 09 Jan 2008 15:55:44 -0800 (PST)
Message-ID: <20080109.155544.136768603.davem@davemloft.net>
References: <20080109153656.GA16962@pingi.kke.suse.de>
	<20080109.153212.144388472.davem@davemloft.net>
	<20080110.084655.66182071.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: kkeil@suse.de, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53182
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753148AbYAIXzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 18:55:44 -0500
In-Reply-To: <20080110.084655.66182071.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 10 Jan 2008 08:46:55 +0900 (JST)

> In article <20080109.153212.144388472.davem@davemloft.net> (at Wed, 09 Jan 2008 15:32:12 -0800 (PST)), David Miller <davem@davemloft.net> says:
> 
> > I question any RFC mandate that shuts down IP communication on a node
> > because of packets received from remote systems.
> 
> RFC4862 tell us that we SHOULD disable IP communication.
> (IP means IPv6 here; IPv4 is out of scope.)
> In IETF term, a SHOULD is almost a MUST.  We are required to follow
> unless we have very good reason to ignore it.

A DoS by definition is a very good reason.

> > If the TAHI test can trigger this, so can a compromised system on your
> > network and won't that be fun? :-)
> 
> So, I know the specification, but I have ignored it.
> I think it is fine to implent in some way, but I do think we must have
> a switch not to do this.

Because of the above, the existing behavior must still stay the
default.  I hope this is your plan.

By default Linux will not implement this SHOULD, it's a security
issue.

I more and more do not like these conformance tests, they leave no
room whatsoever for handling bugs or ill-specified features in the
specification.
