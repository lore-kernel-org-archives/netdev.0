From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: Re: orinoco upstream merge to kernel status?
Date: Wed, 30 Mar 2005 11:04:41 +1000
Message-ID: <20050330010441.GA6478@localhost.localdomain>
References: <1112110149.16060.13.camel@dcbw.boston.redhat.com> <1112114804.29524.8.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pavel Roskin <proski@gnu.org>
Content-Disposition: inline
In-Reply-To: <1112114804.29524.8.camel@dv>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 29, 2005 at 11:46:44AM -0500, Pavel Roskin wrote:
> On Tue, 2005-03-29 at 10:29 -0500, Dan Williams wrote:
> > Hi,
> > 
> > I've just looked over the diff between current 2.6.12rc1 and upstream
> > "for_linus" branch of the orinoco drivers.  I found that the delta is
> > almost 100% due to monitor mode/scanning code that's found in the
> > upstream driver.  That's the last _important_ piece that has to get
> > merged to the mainline kernel.  It seems all the other trivial pieces
> > have been merged already.
> > 
> > David/Pavel: is it correct that the only bits left are monitor
> > mode/scanning, and that they cannot be separated?  Should that diff just
> > be posted as a patch to netdev?  Or are there other issues with the
> > "for_linus" branch right now that prevent the final merge from
> > occurring?
> > 
> Hi, Dan!
> 
> The remaining differences are only in orinoco.c and orinoco.h.  However,
> it's more than just monitor mode and scanning.  The driver in 2.6.12-rc1
> is basically version 0.14alpha2, and there have been more changes since
> then.  For example, support for joining a specific access point.

More importantly there's the update to the wireless extensions v15
interface.  That accounts for by far the largest part of the current
diff.  I've been procrastinating about separating out that change and
sending to Jeff because it's the largest, ugliest, most likely to
cause breakage, and hardest to test.

> David submitted previous changes.  I can submit the rest if David hasn't
> done it.  David?

Um.. you probably don't want to go straight on to work on it, because
I already have another handful of patches lined up ready to go.
Mostly a few more trivialities.

How about I send those to Jeff today, then feel free to tease out some
more pieces and send them on on top of those.  Just make sure you tell
me what you're doing, so I don't start trying to work on the same
thing.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/people/dgibson
