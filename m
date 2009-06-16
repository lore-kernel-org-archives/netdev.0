From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [RFC] net: refactor multicast/unicast address list
Date: Tue, 16 Jun 2009 14:38:08 +0200
Message-ID: <20090616123808.GK3521@psychotron.englab.brq.redhat.com>
References: <1244889678.13033.6.camel@johannes.local> <1244896094.13033.8.camel@johannes.local> <20090616111842.GG3521@psychotron.englab.brq.redhat.com> <1245151771.9256.3.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35801 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750908AbZFPMiL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2009 08:38:11 -0400
Content-Disposition: inline
In-Reply-To: <1245151771.9256.3.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jun 16, 2009 at 01:29:31PM CEST, johannes@sipsolutions.net wrote:
>On Tue, 2009-06-16 at 13:18 +0200, Jiri Pirko wrote:
>> Sat, Jun 13, 2009 at 02:28:14PM CEST, johannes@sipsolutions.net wrote:
>> >On Sat, 2009-06-13 at 12:41 +0200, Johannes Berg wrote:
>> >> I'm trying to use address lists without netdevs, but as
>> >> a first step I thought it would be good to reduce the
>> >> amount duplicated code between unicast and multicast
>> >> lists.
>> >> 
>> >> After introducing a new 'struct address_list', we can
>> >> unify a lot between these. The next step will probably
>> >> be exporting the __dev_addr_sync and __dev_addr_unsync
>> >> functions so I can use them without a netdev, but this
>> >> cleanup can stand on its own.
>> >
>> >Sorry, this was based against the wrong tree and now I see that in
>> >net-next the lists have diverged significantly. Ignore this.
>> 
>> Yes, I've already converted unicast lists to use list_head there. I'm sending
>> the patch doing the same for multicast lists soon.
>
>Very nice! After that maybe I'll take a look again at moving things into
>a common structure -- I ultimately want to use a multicast list without
>a netdev to sync multiple netdevs onto a common multicast list that is
>not part of a netdev.

I see, hmm, I think I can do this change with my conversion... I was thinking
about similar thing as you suggest before...

Jirka

>
>johannes


