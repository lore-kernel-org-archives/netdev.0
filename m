From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: make packet_type->ak_packet_priv generic
Date: Fri, 04 Apr 2014 10:07:54 -0400 (EDT)
Message-ID: <20140404.100754.1337061118939924472.davem@davemloft.net>
References: <1396614038-31975-1-git-send-email-jiri@resnulli.us>
	<20140404.095420.1460518706334112992.davem@davemloft.net>
	<20140404140325.GB2892@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, vfalico@redhat.com,
	nicolas.dichtel@6wind.com, stephen@networkplumber.org,
	hkchu@google.com, dborkman@redhat.com, willemb@google.com,
	hannes@stressinduktion.org, atzm@stratosphere.co.jp, phil@nwl.cc,
	richardcochran@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51951 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752736AbaDDOGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 10:06:20 -0400
In-Reply-To: <20140404140325.GB2892@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 4 Apr 2014 16:03:25 +0200

> Fri, Apr 04, 2014 at 03:54:20PM CEST, davem@davemloft.net wrote:
>>From: Jiri Pirko <jiri@resnulli.us>
>>Date: Fri,  4 Apr 2014 14:20:38 +0200
>>
>>> The priv is used now by af_packet. Rename it to make it useable for
>>> others as well. Also, introduce packet_id_match to move the sk matching
>>> from skb_loop_sk to af_packet code where it belongs.
>>> 
>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>
>>Firstly, net-next is closed.
> 
> Dave, it would be really great if you stick with the same email subject
> when you declare net-next closed. I was looking for "CLOSED" but now the
> subject is "no new feature patches please" which I missed.

Sorry, that's not a reasonable request.

It is very clear from the subject line I choose what the message is
about.  I don't have to use an ALL CAPS subject line "just because"

>>Secondly, submit this with the unmentioned and mysterious "other
>>user", there currently are none.
> 
> There is none atm. But anyway, the struct field name should be generic,
> cause this is not specific to af_packet. Anybody might want to pass a
> "priv".

No, because it makes it clear what the one and only user is.

Any new user would be seriously frowned upon, because this is
an easy side channel for proprietary extensions to the networking.
