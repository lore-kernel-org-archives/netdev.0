From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH v2 0/9] bql: Byte Queue Limits
Date: Mon, 08 Aug 2011 09:06:24 -0400
Message-ID: <1312808784.17202.39.camel@mojatatu>
References: <alpine.DEB.2.00.1108072129010.13386@pokey.mtv.corp.google.com>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:47456 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753540Ab1HHNGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 09:06:33 -0400
Received: by gwaa12 with SMTP id a12so561168gwa.19
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2011 06:06:32 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1108072129010.13386@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

Where are the throughput numbers? I think the tps may be sufficient
proof point for latency.
No comment on the code but on the concept.
Essentially what you are implementing is two things in one:
- byte counting (instead of packet counting we use at that layer)
- pseudo active queue management

For wired connections I think the big deal is in improved
runtime memory saving (your perf numbers are kinda ok).
The challenge is going to be with wireless where the underlying
bandwidth changes (and therefore the optimal queue size varies
more frequently). The problem with active queue management is
getting the feedback loop to be more accurate and i think there
will be challenges with wired devices.
I notice that you dont have any wireless devices;
but it would be nice for someone to check this out on wireless.
CCing Johannes - maybe he has some insight.

cheers,
jamal



