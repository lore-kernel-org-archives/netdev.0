From: Kostantinos Katsaros <dinos.katsaros@gmail.com>
Subject: SCTP research inquiry
Date: Wed, 3 Sep 2014 18:07:30 +0100
Message-ID: <CAHJk9CcBb5VUs9vibXW1QBxPONcmitFSzA9KPZj46dW+6WLKdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:46205 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932670AbaICRHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 13:07:31 -0400
Received: by mail-la0-f49.google.com with SMTP id b17so10165469lan.22
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 10:07:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear NetDev list,

I am a researcher from Univ. of Surrey. I know that this list is
mainly for developers of linux-kernel but I want to ask for some help
to understand the SCTP implementation and pointers to some aspects.

What I would actually like to do, is to modify the default SCTP
operation with respect to primary/secondary interface selection and
analyse it in simulations with NS-3. However, I haven't found an API
or some other help and I was advised to contact this list. I know that
NS-3 is capable of using linux-kernel implementations through the use
of DCE, but my issue here is in the SCTP implementation.


There a few questions I have in a basic scenario with two nodes
connected via 2 interfaces.

- How can I dynamically select which of the two interfaces is primary?
Which method is responsible or should be called to switch?

- I guess that SCTP has some variable holding the estimated RTT on
each path (also used for calculating RTO). Is this accessible and how?
I would like to use this as a triggering mechanism to the switch
method above. In principle select the path with the minimum RTT.

- In a similar way of TCP Westwood (Plus), I would like to estimate
the available bandwidth and use this as trigger.

- Finally, I want to monitor the ratio (packets or bytes sent) on each
of the available paths. How can I implement such mechanism? Do I have
to implement a 'sniffer'?


I would appreciate any help, pointers, code snippets.


Regards,

Kostas
