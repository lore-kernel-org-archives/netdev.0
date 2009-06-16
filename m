From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [RFC] net: refactor multicast/unicast address list
Date: Tue, 16 Jun 2009 13:18:43 +0200
Message-ID: <20090616111842.GG3521@psychotron.englab.brq.redhat.com>
References: <1244889678.13033.6.camel@johannes.local> <1244896094.13033.8.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42836 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752526AbZFPLSq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2009 07:18:46 -0400
Content-Disposition: inline
In-Reply-To: <1244896094.13033.8.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jun 13, 2009 at 02:28:14PM CEST, johannes@sipsolutions.net wrote:
>On Sat, 2009-06-13 at 12:41 +0200, Johannes Berg wrote:
>> I'm trying to use address lists without netdevs, but as
>> a first step I thought it would be good to reduce the
>> amount duplicated code between unicast and multicast
>> lists.
>> 
>> After introducing a new 'struct address_list', we can
>> unify a lot between these. The next step will probably
>> be exporting the __dev_addr_sync and __dev_addr_unsync
>> functions so I can use them without a netdev, but this
>> cleanup can stand on its own.
>
>Sorry, this was based against the wrong tree and now I see that in
>net-next the lists have diverged significantly. Ignore this.

Yes, I've already converted unicast lists to use list_head there. I'm sending
the patch doing the same for multicast lists soon.

Jirka
>
>johannes


