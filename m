From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 0/2] bonding: extend round-robin mode
Date: Wed, 06 Nov 2013 18:51:42 +0100
Message-ID: <527A81AE.2070400@redhat.com>
References: <1383655902-18744-1-git-send-email-nikolay@redhat.com> <23278.1383756949@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	vfalico@redhat.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36427 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755382Ab3KFRvz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Nov 2013 12:51:55 -0500
In-Reply-To: <23278.1383756949@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/06/2013 05:55 PM, Jay Vosburgh wrote:
> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> 
>> This small patchset adds a new option called packets_per_slave to the
>> bonding which aims to extend round-robin mode with the following effects:
>> 0 - choose the slave id at random
>> 1 - packet per slave (standard round-robin, default option value)
>>> 1 - transmit >1 packets per slave, switch the slaves in round-robin
>> Patch02 adds a description for the new option to the bonding documentation.
> 
> 	Could you explain why this is useful?  My guess is that you're
> trying to synchronize with the packet receive processing of a peer
> (perhaps for GRO?), but I think it would be useful to explain the
> utility of this.
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> 
Hi Jay,
Yes, that is one good use case, I'm also experimenting with a user-space
software that uses various heuristics and tunes this option (e.g., TCP-RR
case). I've been playing with this option for the past 3 weeks or so and
have to move on to some real-world tests, since my current environment
consists only of VMs and that's nowhere near the real world :-)
If your intention is to include such information in the bonding
documentation then I'll need some more time to gather it, and can do it as
either a follow-up or we can just drop this now and I'll re-post once I've
some definite real(lab)-world results.

Nik
