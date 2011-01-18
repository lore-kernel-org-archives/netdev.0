From: David Miller <davem@davemloft.net>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Tue, 18 Jan 2011 12:39:42 -0800 (PST)
Message-ID: <20110118.123942.48516205.davem@davemloft.net>
References: <20110118.020702.115924992.davem@davemloft.net>
	<20110118102437.GB7520@ff.dom.local>
	<1295359503.2066.10.camel@mojatatu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, pablo@netfilter.org,
	arthur.marsh@internode.on.net, jengelh@medozas.de,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46123
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752780Ab1ARUjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 15:39:09 -0500
In-Reply-To: <1295359503.2066.10.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Tue, 18 Jan 2011 09:05:03 -0500

> On Tue, 2011-01-18 at 10:24 +0000, Jarek Poplawski wrote:
> 
>> Do you all expect all users manage to upgrade avahi app before
>> changing their stable kernel? I mean "own distro" users especially.
> 
> Unfortunately if that app is widely deployed, it is not pragmatic
> to break it in the name of pedanticity. i.e.
> Be conservative in what you send (clearly Avahi is farting all over the
> place) but more importantly be a nice liberal in what you accept.
> Maybe tell them if you have the cycles about their bad behavior.
> The important part is the GET (kind = 2). The DUMP as Jarek says
> is merely a utility to extrapolate that we need you to
> get everything.. So it is not such a big deal if someone passes
> extraneous senseless flags. Wrong? yes.

Fair enough, I'll revert the netlink patch.
