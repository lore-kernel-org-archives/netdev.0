From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH RFC net-next] net: Allow name change of IFF_UP interfaces
Date: Thu, 10 Aug 2017 18:33:51 +0200
Message-ID: <877eybs7ps.fsf@vitty.brq.redhat.com>
References: <20170809104202.30959-1-vkuznets@redhat.com>
        <CAPA1RqA0q3W-3PsqDpY8_xiBB18SCWTV1gT+BKOTqQfAA5D8Fg@mail.gmail.com>
        <87efskye74.fsf@vitty.brq.redhat.com> <20170809161027.GA28694@lunn.ch>
        <871sojyfv0.fsf@vitty.brq.redhat.com>
        <1502355817.4936.9.camel@edumazet-glaptop3.roam.corp.google.com>
        <87poc3wxkl.fsf@vitty.brq.redhat.com> <20170810141358.GD24790@lunn.ch>
        <87lgmrsawo.fsf@vitty.brq.redhat.com> <20170810162722.GH24790@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48636 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752967AbdHJQdy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Aug 2017 12:33:54 -0400
In-Reply-To: <20170810162722.GH24790@lunn.ch> (Andrew Lunn's message of "Thu,
        10 Aug 2017 18:27:22 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> On Thu, Aug 10, 2017 at 05:24:55PM +0200, Vitaly Kuznetsov wrote:
>> Andrew Lunn <andrew@lunn.ch> writes:
>> 
>> >> We are - rtnetlink_event() does the job. We, however, don't have a
>> >> special IFLA_EVENT_* for name change and end up with IFLA_EVENT_NONE.
>> >
>> > What is in this event? Old and new name? Just the new name?
>> 
>> Basically, it's everything we know about the interface - type, index,
>> name, mtu, qdisc, ... - see rtnl_fill_ifinfo(). Back to your question -
>> it's only the new name.
>
> So the program needs to keep track of ifindex to know which interface
> has changed name. Doable.
>

Yes, and I'd expect that's what these daemons do nowdays to track name
changes for down interfaces (if/when they care).

> I still expect this has the potential to break something. You probably
> should be asking on linux-api for the API experts opinion.
>

Good idea, I'll do RFCv2 submission.

-- 
  Vitaly
