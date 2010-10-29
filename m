From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH 0/15] RFC: create drivers/net/legacy for ISA, EISA, MCA
 drivers
Date: Fri, 29 Oct 2010 17:26:09 -0400
Message-ID: <4CCB3BF1.7070000@windriver.com>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com> <1288316896.1836.41.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53058 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932951Ab0J2V0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 17:26:14 -0400
In-Reply-To: <1288316896.1836.41.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-10-28 09:48 PM, Joe Perches wrote:
> On Thu, 2010-10-28 at 21:19 -0400, Paul Gortmaker wrote:
>> The drivers/net dir has a lot of files - originally there were
>> no subdirs, but at least now subdirs are being used effectively.
>> But the original drivers from 10+ years ago are still right
>> there at the top.  This series creates a drivers/net/legacy dir.
> 
> Hi Paul.
> 
> I like this idea.
> 
> I suggest a bit of a further grouping by using a
> drivers/net/ethernet directory and putting those
> legacy drivers in a new subdirectory
> drivers/net/ethernet/legacy.

That is a substantially larger change, since you'd now be
relocating nearly every remaining driver, i.e. all the
relatively modern 100M and GigE drivers.  Plus what do you
do with the sb1000 - create drivers/cablemodem/legacy
just for one file?  Or the ethernet drivers already in
existing subdirs, like arm and pcmcia -- do we move those?

With this, I tried to aim for a significant gain (close to 1/3
less files) within what I felt was a reasonable sized change
set that had a chance of getting an overall OK from folks.
Giant "flag-day" type mammoth changesets are a PITA for all.

> 
>> The initial target is things like ISA/EISA/MCA drivers, and with
>> that alone, we can get close to 90 files out of drivers/net.
>> Plus, by having a semi-defined description for legacy as being
>> "drivers more than 10 years old" we'll always have a destination
>> for drivers as they fall out of maintainership and use.
> 
> I think legacy is "old and not sold or used much anymore".

I tried to stick to having both, ie. old + not used much,
in what I chose for my initial group.   Where "old" is
meant to apply to the hardware, and not to the driver. 

> 
> I believe you're not moving 3c59x as that's relatively
> still popular even though it's nearly 15 years old.
> 
> Or maybe that was just an oversight...

I didn't want to include any drivers in the initial group
that I thought might sidetrack the issue by being contentious
(clearly I was off by one) -- the point being, that once the
base infrastructure and initial group of (almost) universally
agreed upon ones is in, more can be discussed and added later,
as appropriate.

Paul.

> 
> 
> 

