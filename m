From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Linux, tcpdump and vlan
Date: Thu, 19 Jul 2007 17:45:13 +0200
Message-ID: <m38x9cbdo6.fsf@maximus.localdomain>
References: <878246.51044.qm@web56608.mail.re3.yahoo.com>
	<469E9AC8.3090603@trash.net> <m3zm1sbjzl.fsf@maximus.localdomain>
	<20070719144131.0c230c8f@oldman.hamilton.local>
	<m3k5swbhfv.fsf@maximus.localdomain>
	<20070719160033.628f39e1@oldman.hamilton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	andrei radulescu-banu <iubica2@yahoo.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:46773 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937713AbXGSPpP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 11:45:15 -0400
In-Reply-To: <20070719160033.628f39e1@oldman.hamilton.local> (Stephen Hemminger's message of "Thu, 19 Jul 2007 16:00:33 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> writes:

> Not at runtime, acceleration is always on if you compile kernel with vlan
> support.  That is a design mistake as far as I can tell.

I think so.

>> However seeing unknown tags on master device (with tcpdump etc)
>> would certainly be useful.
>
> Only in promiscuous mode. In some sense tag is part of the mac address.

Well, in "some sense" maybe, though the MAC address is rather
strictly defined to be a 6-octet value. I can live with
promiscous anyway, it's really minor issue.
-- 
Krzysztof Halasa
