From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/15] RFC: create drivers/net/legacy for ISA, EISA, MCA
 drivers
Date: Fri, 29 Oct 2010 15:08:47 -0700
Message-ID: <1288390127.28828.225.camel@Joe-Laptop>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
	 <1288316896.1836.41.camel@Joe-Laptop>  <4CCB3BF1.7070000@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3663 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755739Ab0J2WIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Oct 2010 18:08:49 -0400
In-Reply-To: <4CCB3BF1.7070000@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-10-29 at 17:26 -0400, Paul Gortmaker wrote:
> On 10-10-28 09:48 PM, Joe Perches wrote:
> > On Thu, 2010-10-28 at 21:19 -0400, Paul Gortmaker wrote:
> >> The drivers/net dir has a lot of files - originally there were
> >> no subdirs, but at least now subdirs are being used effectively.
> >> But the original drivers from 10+ years ago are still right
> >> there at the top.  This series creates a drivers/net/legacy dir.
> > I like this idea.
> > I suggest a bit of a further grouping by using a
> > drivers/net/ethernet directory and putting those
> > legacy drivers in a new subdirectory
> > drivers/net/ethernet/legacy.
> That is a substantially larger change, since you'd now be
> relocating nearly every remaining driver, i.e. all the
> relatively modern 100M and GigE drivers.

Files to not need immediate renames.

Renames could happen when the appropriate maintainer
wants to or gets coerced to conform to some new
file layout standard.

I had submitted a related RFC patch:

https://patchwork.kernel.org/patch/244641/

and then had some off list discussions
with Jeff Kirsher from Intel.

Perhaps Jeff will chime in.

> Plus what do you
> do with the sb1000 - create drivers/cablemodem/legacy
> just for one file?

I never looked at that particular driver before.
Maybe.  I don't have a strong opinion.  Leaving
it where it is might be OK.

> Or the ethernet drivers already in
> existing subdirs, like arm and pcmcia -- do we move those?

Maybe.  If there's no demand, there's no absolute need to
move it at all.  I think a reasonable goal is to have some
sensible and consistent file layout scheme though.

There are arch specific directories under various drivers/...
so I don't see a need to move directories like drivers/net/arm
or drivers/s390.

> With this, I tried to aim for a significant gain (close to 1/3
> less files) within what I felt was a reasonable sized change
> set that had a chance of getting an overall OK from folks.
> Giant "flag-day" type mammoth changesets are a PITA for all.

I believe there's no need for a flag-day.
File renames could happen gradually or not at all.


