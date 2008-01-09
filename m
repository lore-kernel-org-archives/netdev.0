From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: Linux IPv6 DAD not full conform to RFC 4862 ?
Date: Thu, 10 Jan 2008 08:46:55 +0900 (JST)
Message-ID: <20080110.084655.66182071.yoshfuji@linux-ipv6.org>
References: <20080109153656.GA16962@pingi.kke.suse.de>
	<20080109.153212.144388472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kkeil@suse.de, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34741 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754341AbYAIXqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 18:46:53 -0500
In-Reply-To: <20080109.153212.144388472.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080109.153212.144388472.davem@davemloft.net> (at Wed, 09 Jan 2008 15:32:12 -0800 (PST)), David Miller <davem@davemloft.net> says:

> I question any RFC mandate that shuts down IP communication on a node
> because of packets received from remote systems.

RFC4862 tell us that we SHOULD disable IP communication.
(IP means IPv6 here; IPv4 is out of scope.)
In IETF term, a SHOULD is almost a MUST.  We are required to follow
unless we have very good reason to ignore it.

> If the TAHI test can trigger this, so can a compromised system on your
> network and won't that be fun? :-)

So, I know the specification, but I have ignored it.
I think it is fine to implent in some way, but I do think we must have
a switch not to do this.

--yoshfuji
