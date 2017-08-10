From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC net-next] net: Allow name change of IFF_UP interfaces
Date: Thu, 10 Aug 2017 16:13:58 +0200
Message-ID: <20170810141358.GD24790@lunn.ch>
References: <20170809104202.30959-1-vkuznets@redhat.com>
 <CAPA1RqA0q3W-3PsqDpY8_xiBB18SCWTV1gT+BKOTqQfAA5D8Fg@mail.gmail.com>
 <87efskye74.fsf@vitty.brq.redhat.com>
 <20170809161027.GA28694@lunn.ch>
 <871sojyfv0.fsf@vitty.brq.redhat.com>
 <1502355817.4936.9.camel@edumazet-glaptop3.roam.corp.google.com>
 <87poc3wxkl.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59712 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751492AbdHJOOA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Aug 2017 10:14:00 -0400
Content-Disposition: inline
In-Reply-To: <87poc3wxkl.fsf@vitty.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We are - rtnetlink_event() does the job. We, however, don't have a
> special IFLA_EVENT_* for name change and end up with IFLA_EVENT_NONE.

What is in this event? Old and new name? Just the new name?

     Andrew
