From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: SCTP research inquiry
Date: Wed, 03 Sep 2014 16:44:07 -0400
Message-ID: <54077D97.9060608@gmail.com>
References: <CAHJk9CcBb5VUs9vibXW1QBxPONcmitFSzA9KPZj46dW+6WLKdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Kostantinos Katsaros <dinos.katsaros@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:45948 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754017AbaICUoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 16:44:11 -0400
Received: by mail-qg0-f48.google.com with SMTP id z107so8801033qgd.7
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 13:44:10 -0700 (PDT)
In-Reply-To: <CAHJk9CcBb5VUs9vibXW1QBxPONcmitFSzA9KPZj46dW+6WLKdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2014 01:07 PM, Kostantinos Katsaros wrote:
> Dear NetDev list,
> 
> I am a researcher from Univ. of Surrey. I know that this list is
> mainly for developers of linux-kernel but I want to ask for some help
> to understand the SCTP implementation and pointers to some aspects.
> 
> What I would actually like to do, is to modify the default SCTP
> operation with respect to primary/secondary interface selection and
> analyse it in simulations with NS-3. However, I haven't found an API
> or some other help and I was advised to contact this list. I know that
> NS-3 is capable of using linux-kernel implementations through the use
> of DCE, but my issue here is in the SCTP implementation.
> 
> 
> There a few questions I have in a basic scenario with two nodes
> connected via 2 interfaces.

Are you looking for user-space API that provide the information you need?
The reason I ask is that all I've seen of dce requires you to have
an posix-like application to run on top of the protocol you want to use.
I don't know if DCE allows you directly call linux kernel functions.

Based on the above answer, I can point you more resources.

-vlad

> 
> - How can I dynamically select which of the two interfaces is primary?
> Which method is responsible or should be called to switch?
> 
> - I guess that SCTP has some variable holding the estimated RTT on
> each path (also used for calculating RTO). Is this accessible and how?
> I would like to use this as a triggering mechanism to the switch
> method above. In principle select the path with the minimum RTT.
> 
> - In a similar way of TCP Westwood (Plus), I would like to estimate
> the available bandwidth and use this as trigger.
> 
> - Finally, I want to monitor the ratio (packets or bytes sent) on each
> of the available paths. How can I implement such mechanism? Do I have
> to implement a 'sniffer'?
> 
> 
> I would appreciate any help, pointers, code snippets.
> 
> 
> Regards,
> 
> Kostas
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
