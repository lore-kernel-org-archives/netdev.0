From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH] qos: Limit a filter's priority to a 16 bit value
Date: Fri, 01 May 2009 22:35:32 -0400
Message-ID: <1241231732.7162.13.camel@dogo.mojatatu.com>
References: <273D38FBE7C6FE46A1689FCD014A0B8B495C016A@azsmsx505.amr.corp.intel.com>
	 <1241229126.7162.5.camel@dogo.mojatatu.com>
	 <273D38FBE7C6FE46A1689FCD014A0B8B495C01C0@azsmsx505.amr.corp.intel.com>
	 <20090501.191854.218400455.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: robert.w.love@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f196.google.com ([209.85.221.196]:39474 "EHLO
	mail-qy0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbZEBCf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 22:35:58 -0400
Received: by qyk34 with SMTP id 34so3919885qyk.33
        for <netdev@vger.kernel.org>; Fri, 01 May 2009 19:35:58 -0700 (PDT)
In-Reply-To: <20090501.191854.218400455.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-05-01 at 19:10 -0700, Love, Robert W wrote:

> I don't want our script to yank out the
> multiq qdisc just because FCoE traffic has stopped. The FCoE
> script doesn't know if the user has other filters applied for
> that interface/qdisc. The script should just remove its
> filters and not disrupt anything else on the chain.

True - but if you specify the prio on add/del you should be fine
though.
I looked at about 15-20 scripts and i noticed i always specified
the priority; i suspect most people do thats why noone bumped into
this over the years.

On Fri, 2009-05-01 at 19:18 -0700, David Miller wrote:

> So could I just get that one-liner fix patch from somebody?

Robert, would you do the honors of submitting the patch since
you did all the hardwork?

> Thanks :-)
> 
> Meanwhile, on the issue of how this value is stored, perhaps someone
> intended to support "classful" filter priorities, just as we support
> classful qdiscs.  Or perhaps someone had the idea to store the
> protocol in there as well, who knows :-)

I cant remember the reason. Alexey probably would - but i think the
important point is it is consistent everywhere.

cheers,
jamal

