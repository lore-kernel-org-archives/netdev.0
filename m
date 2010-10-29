From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/15] RFC: create drivers/net/legacy for ISA, EISA, MCA
 drivers
Date: Thu, 28 Oct 2010 18:48:16 -0700
Message-ID: <1288316896.1836.41.camel@Joe-Laptop>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3653 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756306Ab0J2BsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 21:48:18 -0400
In-Reply-To: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-10-28 at 21:19 -0400, Paul Gortmaker wrote:
> The drivers/net dir has a lot of files - originally there were
> no subdirs, but at least now subdirs are being used effectively.
> But the original drivers from 10+ years ago are still right
> there at the top.  This series creates a drivers/net/legacy dir.

Hi Paul.

I like this idea.

I suggest a bit of a further grouping by using a
drivers/net/ethernet directory and putting those
legacy drivers in a new subdirectory
drivers/net/ethernet/legacy.

> The initial target is things like ISA/EISA/MCA drivers, and with
> that alone, we can get close to 90 files out of drivers/net.
> Plus, by having a semi-defined description for legacy as being
> "drivers more than 10 years old" we'll always have a destination
> for drivers as they fall out of maintainership and use.

I think legacy is "old and not sold or used much anymore".

I believe you're not moving 3c59x as that's relatively
still popular even though it's nearly 15 years old.

Or maybe that was just an oversight...



