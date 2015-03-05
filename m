From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [ovs-dev] OVS Offload Decision Proposal
Date: Thu, 05 Mar 2015 07:37:53 -0500
Message-ID: <54F84E21.7030207@mojatatu.com>
References: <54F7B76E.4040902@gmail.com> <20150305.000015.1427044514000703740.davem@davemloft.net> <CA+mtBx_Q5Zp58ZkBB0oeyHm5NC8sg1kx=uzTN_8TYG6zYh8yUA@mail.gmail.com> <20150305.014257.974664546228241067.davem@davemloft.net> <54F80815.5030208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, davidch@broadcom.com,
	simon.horman@netronome.com, dev@openvswitch.org,
	netdev@vger.kernel.org, pablo@netfilter.org
To: John Fastabend <john.fastabend@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:44659 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752498AbbCEMh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 07:37:56 -0500
Received: by iecar1 with SMTP id ar1so75937603iec.11
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 04:37:55 -0800 (PST)
In-Reply-To: <54F80815.5030208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/05/15 02:39, John Fastabend wrote:

>
> The intent was to reserve space in the tables for l2, l3, user space,
> and whatever else is needed. This reservation needs to come from the
> administrator because even the kernel doesn't know how much of my
> table space I want to reserve for l2 vs l3 vs tc vs ... The sizing
> of each of these tables will depend on the use case. If I'm provisioning
> L3 networks I may want to create a large l3 table and no 'tc' table.
> If I'm building a firewall box I might want a small l3 table and a
> large 'tc' table. Also depending on how wide I want my matches in the
> 'tc' case I may consume more or less resources in the hardware.
>

Would kernel boot/module options passed to the driver not suffice?
That implies a central authority that decides what these table size
slicing looks like.

> Once the reservation of resources occurs we wouldn't let user space
> arbitrarily write to any table but only tables that have been
> explicitly reserved for user space to write to.
>

How would one allow for a bypass to create tables (a write command)
but not to write to said tables? likely i am missing something
subtle.

cheers,
jamal
