From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [ovs-dev] OVS Offload Decision Proposal
Date: Thu, 05 Mar 2015 08:16:27 -0500
Message-ID: <54F8572B.4020309@mojatatu.com>
References: <54F7B76E.4040902@gmail.com> <20150305.000015.1427044514000703740.davem@davemloft.net> <CA+mtBx_Q5Zp58ZkBB0oeyHm5NC8sg1kx=uzTN_8TYG6zYh8yUA@mail.gmail.com> <20150305.014257.974664546228241067.davem@davemloft.net> <54F80815.5030208@gmail.com> <54F84E21.7030207@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, davidch@broadcom.com,
	simon.horman@netronome.com, dev@openvswitch.org,
	netdev@vger.kernel.org, pablo@netfilter.org
To: John Fastabend <john.fastabend@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:44598 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbbCENQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 08:16:30 -0500
Received: by igdh15 with SMTP id h15so45585804igd.3
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 05:16:29 -0800 (PST)
In-Reply-To: <54F84E21.7030207@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/05/15 07:37, Jamal Hadi Salim wrote:
> On 03/05/15 02:39, John Fastabend wrote:

> Would kernel boot/module options passed to the driver not suffice?
> That implies a central authority that decides what these table size
> slicing looks like.
>
>> Once the reservation of resources occurs we wouldn't let user space
>> arbitrarily write to any table but only tables that have been
>> explicitly reserved for user space to write to.

Seems i misread what you are saying.
I thought you wanted to just create the tables from user space
directly; however, rereading the above:
you are actually  asking *to write* to these tables directly from user
space ;->

cheers,
jamal
