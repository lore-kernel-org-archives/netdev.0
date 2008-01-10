From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch net-2.6.25 00/10][NETNS][IPV6] make sysctl per namespace
 - V3
Date: Thu, 10 Jan 2008 12:52:07 +0100
Message-ID: <478606E7.6020909@fr.ibm.com>
References: <20080109164533.695191040@localhost.localdomain> <20080110.031544.259471083.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:29570 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759368AbYAJMBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 07:01:51 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m0AC1nGc273112
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 12:01:49 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0AC1nKa2961588
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 13:01:49 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0AC1m25004707
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 13:01:49 +0100
In-Reply-To: <20080110.031544.259471083.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> Date: Wed, 09 Jan 2008 17:45:33 +0100
> 
>> The following patchset makes the ipv6 sysctl to handle multiple
>> network namespaces. Each instance of a network namespace as its own
>> set of sysctl values, that means the behavior of the ipv6 stack can be
>> different depending on the sysctl values setup in the different
>> network namespaces.
> 
> I applied all of this to net-2.6.25 but what a rough half hour
> it was :-/
> 
> Starting at patch #5 there were tons of "space before tab" errors.
> And as I fixed them up, this made subsequent patches need rediffing
> since the contextual lines in patches after #5 needed the whitespace
> fixed up as well.
> 
> I didn't push this back to you because this was already the 3rd round,
> but please show me some love and check this stuff out before
> submission.  GIT gives you effective ways to verify the whitespace
> without even applying the patch.
> 
> ~davem/bin/pcheck:
> 
> #!/bin/sh
> set -x
> git apply --check --whitespace=error-all $1

Sorry, I will check that in the future :|
Many thanks for taking the time to fix that.

   -- Daniel.
