From: jamal <hadi@cyberus.ca>
Subject: Re: [NET_SCHED]: Add mask support to fwmark classifier
Date: Fri, 25 Aug 2006 08:52:20 -0400
Message-ID: <1156510340.5162.145.camel@jzny2>
References: <44EED0FC.4050108@trash.net>
	 <20060825105428.GR3470@postel.suug.ch>  <44EEE6DE.4090703@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:685 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1750798AbWHYMxc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 08:53:32 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GGbBj-0003CY-ON
	for netdev@vger.kernel.org; Fri, 25 Aug 2006 08:53:31 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44EEE6DE.4090703@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-25-08 at 14:02 +0200, Patrick McHardy wrote:
> Thomas Graf wrote:
> > * Patrick McHardy <kaber@trash.net> 2006-08-25 12:29
> > 
> >>The problem is that in order to avoid walking through all filters
> >>contained in one instance, we need to mask the value before the
> >>lookup. This means all filters share the same mask, which is
> >>taken from the first filter created and stored in the filter head.
> >>The user interface however always refers to a single filter,
> >>not the head, so it can't be changed afterwards unless we just
> >>overwrite it whenever a new filter is installed. Both is not
> >>really perfect. The current patch doesn't allow to change the
> >>mark and enforces that all filters use the same one, which I think
> >>is better than allowing inconsistent configurations.
> > 
> > 
> > The other option gets down to replacing the hash table with a
> > list and that's not an option in my opinion. This looks very
> > good to me.
> 
> 
> Great, thanks. I'll send it off to Dave with two similar patches
> for IPv4 and DecNET routing rules.

ACKed by me as well.

cheers,
jamal

