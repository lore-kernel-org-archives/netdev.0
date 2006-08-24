From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: ProxyARP and IPSec
Date: Wed, 23 Aug 2006 21:14:15 -0700
Message-ID: <44ED2797.4070304@zytor.com>
References: <44EBA1FC.5000801@zytor.com>	<20060823191425.GK3470@postel.suug.ch>	<20060823.151424.78711856.davem@davemloft.net>	<20060823231812.GA32394@ms2.inr.ac.ru> <44ECFCF1.10500@zytor.com>	<44ECFD5F.6060901@zytor.com> <1156386043.7302.773.camel@tahini.andynet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([192.83.249.54]:16313 "EHLO
	terminus.zytor.com") by vger.kernel.org with ESMTP id S1030277AbWHXEOz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 00:14:55 -0400
To: Andy Gay <andy@andynet.net>
In-Reply-To: <1156386043.7302.773.camel@tahini.andynet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gay wrote:
>>>>
>>> Just tried it, and it works as advertised.
>>>
>> ... except that OpenSwan will rip out the route and install a route 
>> pointing to eth0, thus breaking the thing again.
> 
> Use a custom updown script with Openswan to fix that.
> 

*Nod.*

I'm thinking that David definitely has a point about having a usability 
problem, though.  All other kind of tunnels have endpoint devices 
associated with them, and that would make all these kinds of problems go 
away, plus would be nicer to deal with in iptables, dealing with routed 
IPsec connections, etc.

	-hpa
