From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: make ipv6_sysctl_register to return a value
Date: Wed, 09 Jan 2008 10:56:48 +0100
Message-ID: <47849A60.1020909@fr.ibm.com>
References: <47828DEB.9070301@fr.ibm.com> <20080109.002632.136758957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:40998 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225AbYAIKGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 05:06:14 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id m09A6C8e180102
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 10:06:13 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m09A6CdV2699518
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 11:06:12 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m09A6Cn2008205
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 11:06:12 +0100
In-Reply-To: <20080109.002632.136758957.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Why did you post this again?  It's identical to patch 1/9
> from the previous series you sent out.
> 
> This is confusing, since it makes me think you wanted me to
> perhaps do something different or update an already
> submitted patch.

I thought you was expecting a new netns ipv6 sysctl series and ignored 
the current one. While I was looking at them again I found a problem and 
I wanted to fix that before resending. In the meantime, there were three 
independant trivial patches I wanted to send as a pre-requesite for the 
incoming sysctl patches. Bad idea ... :)

  - make ipv6_sysctl_register to return a value
  - make a subsystem for af_inet6
  - add ipv6 structure for netns

With the sysctl Pavel's patch, the first one does not apply.

To clear out any confusion, please can you just ignore all my previous 
patches, I will resend a new serie rebased on the work done by Pavel.

Sorry for the inconvenience.

Thanks.

   -- Daniel

