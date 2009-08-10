From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] sky2: driver update
Date: Sun, 09 Aug 2009 21:09:43 -0700 (PDT)
Message-ID: <20090809.210943.256633746.davem@davemloft.net>
References: <20090806161213.148382653@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39969
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750788AbZHJEJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 00:09:34 -0400
In-Reply-To: <20090806161213.148382653@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 06 Aug 2009 09:12:13 -0700

> This undoes the prematurely committed sky2 transmit logic changes
> and applies Mike's later changes.
> Here is a corrected patch stream please apply this to 2.6.31-rc5

I have to pass on this set, too many problems:

1) You didn't provide explicit "From: " lines for patches where
   you were not the author Stephen.  I could guess from the
   Signoff lines but I'd rather not.

2) I can almost swallow the cleanups if they make the bug fix
   coming up afterwards to be understood more easily.

   But I'm not going to apply patches right now that remove locking
   beause it "seems safe" or "should be ok".  That's absolutely not
   appropriate right now unless it fixes a performance regression
   explicitly listed in the formal regression list.  This is in
   reference to patch #5.

   If this is a prerequisite for patch #6 in some way (that's my
   guess), please make this more explicit, or even better change
   words like "should" (that sounds like "I'm not sure") into
   "is" when the commit message describes how the locks are no
   longer needed at that spot.

   Another idea is to combine #5 and #6 and explain the dependency
   in the commit message.

Also, to be honest, this kind of commit count is way too high at this
late stage of the RC series.  Nothing in here is super critical,
and none of it (to my knowledge) is in the regression list either.

And I informed you in private that the main reason I kept asking you
to be more responsive over the past month or so to sky2 patches and
bug reports was so that patches trickled in gradually, instead of
being dumped all at once way too late in the RC series.
