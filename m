From: Chris Snook <csnook@redhat.com>
Subject: Re: atl1: use magic packet wake-on-lan only
Date: Wed, 12 Nov 2008 12:37:00 -0500
Message-ID: <491B143C.5050404@redhat.com>
References: <20081109150530.3eb555f9@osprey.hogchain.net>	<49188091.3090709@redhat.com> <20081111183546.72de1714@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, Jie.yang@atheros.com, netdev@vger.kernel.org
To: "J. K. Cliburn" <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59389 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751793AbYKLRhM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 12:37:12 -0500
In-Reply-To: <20081111183546.72de1714@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

J. K. Cliburn wrote:
> On Mon, 10 Nov 2008 13:42:25 -0500
> Chris Snook <csnook@redhat.com> wrote:
> 
>> J. K. Cliburn wrote:
>>> atl1: use magic packet wake-on-lan only
>>>
>>> Of the various WOL options provided in include/linux/ethtool.h, the
>>> L1 NIC supports only magic packet.  Remove all options except magic
>>> packet from the atl1 driver.
>> Technically, we could implement the rest via the programmable 
>> pattern-matching hardware, but that would be an immense amount of
>> work.
> 
> Thanks for the pointer to the pattern matching capability.  I had
> forgotten about it.
> 
> What prompted the patch was a user asking some questions off-list about
> the L1 and WOL, and I realized the atl1 driver was advertising WOL
> options that weren't implemented.
> 
> I think the magic-packet-only patch I submitted to Jeff is still
> relevant, but I'm going to explore the pattern matching capability and
> see if we can implement some additional WOL options.  IMHO, though,
> those should be provided in a separate (future) patch.  Do you agree?
> 
> Jay

Completely.  Programming the pattern matching hardware is a lot more 
involved than setting a single bit in the hardware.

Are there any other NICs that have pattern-matching WoLAN capability? 
If so, how do their drivers take advantage of them?  If it turns out to 
be a widely underutilized feature, it might make sense to let ethtool do 
the dirty work.

-- Chris
