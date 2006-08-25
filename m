From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET_SCHED]: Add mask support to fwmark classifier
Date: Fri, 25 Aug 2006 14:02:38 +0200
Message-ID: <44EEE6DE.4090703@trash.net>
References: <44EED0FC.4050108@trash.net> <20060825105428.GR3470@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54440 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751452AbWHYMCm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 08:02:42 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060825105428.GR3470@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Patrick McHardy <kaber@trash.net> 2006-08-25 12:29
> 
>>The problem is that in order to avoid walking through all filters
>>contained in one instance, we need to mask the value before the
>>lookup. This means all filters share the same mask, which is
>>taken from the first filter created and stored in the filter head.
>>The user interface however always refers to a single filter,
>>not the head, so it can't be changed afterwards unless we just
>>overwrite it whenever a new filter is installed. Both is not
>>really perfect. The current patch doesn't allow to change the
>>mark and enforces that all filters use the same one, which I think
>>is better than allowing inconsistent configurations.
> 
> 
> The other option gets down to replacing the hash table with a
> list and that's not an option in my opinion. This looks very
> good to me.


Great, thanks. I'll send it off to Dave with two similar patches
for IPv4 and DecNET routing rules.
