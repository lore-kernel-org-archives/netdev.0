From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 0/3] cxgb - driver fixes.
Date: Sat, 01 Dec 2007 15:26:15 -0800
Message-ID: <4751ED97.5090804@chelsio.com>
References: <474C8BF8.9080609@chelsio.com> <474F0422.6090309@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, NetDev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, Greg KH <greg@kroah.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:8869 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752648AbXLAX0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 18:26:42 -0500
In-Reply-To: <474F0422.6090309@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> Divy Le Ray wrote:
>> Jeff,
>>
>> I'm submitting a patch series for inclusion in 2.6.24 for the cxgb 
>> driver.
>> The patches are built against Linus'git tree.
>>
>> Here is a brief description:
>> - Ensure that GSO skbs have enough headroom before encapsulating them,
>> - Fix a crash in NAPI mode,
>> - Fix statistics accounting and report.
>
> We ran pktgen overnight on 2.6.23 with patch 1 and 3 applied (patch 2
> not needed on .23 it seems) and it was stable at about 1.5Gbps 
> bi-directional
> using 1500 MTU sized frames.
>
> We'll run some more tests with user-space TCP & UDP today, but it 
> looks good
> so far.
>
> Perhaps these patches should be considered for .23 stable as well?
>
> Thanks,
> Ben
>

Yes, patches 1 and 3 could be considered for .22 and .23-stable, along 
with the previous fix:
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=7de6af0f23b25df8da9719ecae1916b669d0b03d

Cheers,
Divy
