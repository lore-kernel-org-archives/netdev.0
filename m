From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 0/3] cxgb - driver fixes.
Date: Tue, 11 Dec 2007 14:47:16 -0800
Message-ID: <20071211224716.GA17643@kroah.com>
References: <474C8BF8.9080609@chelsio.com> <474F0422.6090309@candelatech.com> <4751ED97.5090804@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	Jeff Garzik <jeff@garzik.org>, NetDev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:34050 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758937AbXLKWvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 17:51:04 -0500
Content-Disposition: inline
In-Reply-To: <4751ED97.5090804@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 01, 2007 at 03:26:15PM -0800, Divy Le Ray wrote:
> Ben Greear wrote:
>> Divy Le Ray wrote:
>>> Jeff,
>>>
>>> I'm submitting a patch series for inclusion in 2.6.24 for the cxgb 
>>> driver.
>>> The patches are built against Linus'git tree.
>>>
>>> Here is a brief description:
>>> - Ensure that GSO skbs have enough headroom before encapsulating them,
>>> - Fix a crash in NAPI mode,
>>> - Fix statistics accounting and report.
>>
>> We ran pktgen overnight on 2.6.23 with patch 1 and 3 applied (patch 2
>> not needed on .23 it seems) and it was stable at about 1.5Gbps 
>> bi-directional
>> using 1500 MTU sized frames.
>>
>> We'll run some more tests with user-space TCP & UDP today, but it looks 
>> good
>> so far.
>>
>> Perhaps these patches should be considered for .23 stable as well?
>>
>> Thanks,
>> Ben
>>
>
> Yes, patches 1 and 3 could be considered for .22 and .23-stable, along with 
> the previous fix:
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=7de6af0f23b25df8da9719ecae1916b669d0b03d

Can you send all of the individual patches you wish to have applied to
the -stable tree to stable@kernel.org so that we can properly determine
exactly which patches you are referring to?

Also, make sure they are already in Linus's tree before telling us about
them.

thanks,

greg k-h
