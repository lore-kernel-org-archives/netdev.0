From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] net: make packet_type->ak_packet_priv generic
Date: Fri, 4 Apr 2014 16:03:25 +0200
Message-ID: <20140404140325.GB2892@minipsycho.brq.redhat.com>
References: <1396614038-31975-1-git-send-email-jiri@resnulli.us>
 <20140404.095420.1460518706334112992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, edumazet@google.com, vfalico@redhat.com,
	nicolas.dichtel@6wind.com, stephen@networkplumber.org,
	hkchu@google.com, dborkman@redhat.com, willemb@google.com,
	hannes@stressinduktion.org, atzm@stratosphere.co.jp, phil@nwl.cc,
	richardcochran@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:53927 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090AbaDDOD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 10:03:29 -0400
Received: by mail-wi0-f176.google.com with SMTP id r20so1346719wiv.3
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 07:03:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140404.095420.1460518706334112992.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Apr 04, 2014 at 03:54:20PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Fri,  4 Apr 2014 14:20:38 +0200
>
>> The priv is used now by af_packet. Rename it to make it useable for
>> others as well. Also, introduce packet_id_match to move the sk matching
>> from skb_loop_sk to af_packet code where it belongs.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>Firstly, net-next is closed.

Dave, it would be really great if you stick with the same email subject
when you declare net-next closed. I was looking for "CLOSED" but now the
subject is "no new feature patches please" which I missed.

Subject like "*net-next is CLOSED*" or some other constant nicely
visible string would avoid people like me miss this and people like you
and Nicolas to remind me :)

>
>Secondly, submit this with the unmentioned and mysterious "other
>user", there currently are none.

There is none atm. But anyway, the struct field name should be generic,
cause this is not specific to af_packet. Anybody might want to pass a
"priv".
