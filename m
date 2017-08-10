From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH RFC net-next] net: Allow name change of IFF_UP interfaces
Date: Thu, 10 Aug 2017 17:24:55 +0200
Message-ID: <87lgmrsawo.fsf@vitty.brq.redhat.com>
References: <20170809104202.30959-1-vkuznets@redhat.com>
        <CAPA1RqA0q3W-3PsqDpY8_xiBB18SCWTV1gT+BKOTqQfAA5D8Fg@mail.gmail.com>
        <87efskye74.fsf@vitty.brq.redhat.com> <20170809161027.GA28694@lunn.ch>
        <871sojyfv0.fsf@vitty.brq.redhat.com>
        <1502355817.4936.9.camel@edumazet-glaptop3.roam.corp.google.com>
        <87poc3wxkl.fsf@vitty.brq.redhat.com> <20170810141358.GD24790@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39232 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751972AbdHJPY6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Aug 2017 11:24:58 -0400
In-Reply-To: <20170810141358.GD24790@lunn.ch> (Andrew Lunn's message of "Thu,
        10 Aug 2017 16:13:58 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

>> We are - rtnetlink_event() does the job. We, however, don't have a
>> special IFLA_EVENT_* for name change and end up with IFLA_EVENT_NONE.
>
> What is in this event? Old and new name? Just the new name?

Basically, it's everything we know about the interface - type, index,
name, mtu, qdisc, ... - see rtnl_fill_ifinfo(). Back to your question -
it's only the new name.

-- 
  Vitaly
