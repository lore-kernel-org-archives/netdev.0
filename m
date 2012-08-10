From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next] bonding: don't allow the master to become its slave
Date: Fri, 10 Aug 2012 15:04:01 +0200
Message-ID: <20120810130401.GC1543@minipsycho>
References: <20120809195539.GB1783@minipsycho.orion>
 <1344546593.2593.24.camel@bwh-desktop.uk.solarflarecom.com>
 <22811.1344547628@death.nxdomain>
 <20120809.164331.1709422829981798177.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, bhutchings@solarflare.com, jpirko@redhat.com,
	fbl@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net,
	lchiquitto@suse.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:53288 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988Ab2HJNEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 09:04:06 -0400
Received: by wibhr14 with SMTP id hr14so1351818wib.1
        for <netdev@vger.kernel.org>; Fri, 10 Aug 2012 06:04:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120809.164331.1709422829981798177.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Aug 10, 2012 at 01:43:31AM CEST, davem@davemloft.net wrote:
>From: Jay Vosburgh <fubar@us.ibm.com>
>Date: Thu, 09 Aug 2012 14:27:08 -0700
>
>> 	If that's hard to do (and it might be; I'm not aware of a
>> standard way to run up and down those stacks of interfaces, which might
>> not always be vlans in the middle), there's still the priv_flags &
>> IFF_BONDING test that bonding could (and probably should) do itself as
>> well.  The team driver could presumably have a similar test, although I
>> seem to recall that team was allowed to nest.
>> 
>> 	FWIW, I've seen both the top and bottom halves of that picture
>> in use (i.e., bonds consisting of vlans as slaves or bonds with vlans
>> configured above them), but not combined as in your diagram.
>
>We're basically looking for cycles in a complex graph.
>
>Some combination of Jay and Ben's most recent patches, with some minor
>modifications, ought to do it.


Hmm. Would be probably good to have list/table of related devices,
possibly with information about the relation.
After that, every relation add would check for loops.

I will dive in the code over the weekend to see if this is doable in
some nice way.

>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
