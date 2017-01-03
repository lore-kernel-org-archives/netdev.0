From: Mark Greer <mgreer@animalcreek.com>
Subject: Re: [PATCH v3 3/3] nfc: trf7970a: Prevent repeated polling from
 crashing the kernel
Date: Tue, 3 Jan 2017 14:21:36 -0700
Message-ID: <20170103212136.GA9899@animalcreek.com>
References: <1482380314-16440-1-git-send-email-geoff@kuvee.com>
 <1482380314-16440-3-git-send-email-geoff@kuvee.com>
 <20161224060141.GA9069@animalcreek.com>
 <CAO7Z3W+n85jbr8cmj3HJV1c+eL=oRh-XRy+O=iZ+mD=ov2WABA@mail.gmail.com>
 <20161224172439.GA15103@animalcreek.com>
 <CAO7Z3WJa0goJ-VXc7dvyz8imZtqby6QsC0QNH+uRAE8LhxqU2w@mail.gmail.com>
 <20170103163324.GA3184@animalcreek.com>
 <CAO7Z3WK5pF+q0vAoPPie8wXYQPigpGd7W8uQiGSgN79z4=W9uQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
        Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
        Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
        Samuel Ortiz <sameo@linux.intel.com>, robh+dt@kernel.org,
        mark.rutland@arm.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        Justin Bronder <justin@kuvee.com>,
        Jaret Cantu <jaret.cantu@timesys.com>
To: Geoff Lansberry <geoff@kuvee.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:60666 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1761421AbdACVVj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 16:21:39 -0500
Content-Disposition: inline
In-Reply-To: <CAO7Z3WK5pF+q0vAoPPie8wXYQPigpGd7W8uQiGSgN79z4=W9uQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 03, 2017 at 01:35:18PM -0500, Geoff Lansberry wrote:
> On Tue, Jan 3, 2017 at 11:33 AM, Mark Greer <mgreer@animalcreek.com> wrote:
> > On Tue, Dec 27, 2016 at 09:18:32AM -0500, Geoff Lansberry wrote:

> >> In the meantime - here is some more info about how we use it.
> >>
> >> We do use NFC structures.    I did find an interesting clue in that
> >> there are certain bottles that cause neard to segfault,  I'm not sure
> >> what is different about them.  We write a string, like
> >> "coppola_chardonnay_2015" to the bottles.
> >
> > Off the top of my head, it could be the length of the text.
> > It would be useful to compare the data that works to the data
> > that doesn't work.  Can you install NXP's 'TagInfo' app on a
> > smartphone and scan tags with working & non-working data?
> > You can email the data from the app to yourself, edit out
> > the cruft, and share here.
> 
> The data is always the same - and the tags are all the same.  Only
> difference is that the tag is physically different, and perhaps
> orientation; distance from antenna to tag is fixed.

Interesting...  They're all type 2 tags, right?

> I can't even
> write the tags at all, so reading them will show blank.   Also a minor
> but significant detail, is that the tags are embedded in such a way
> that the phone cannot get close enough to them to connect.

This section had me completely confused for a couple minutes until I realized
that you mean that you can read & write the tags using the trf7970a with
an attached antenna but not with your phone.  Is that correct?

If so, try a tag that isn't embedded in something else and move it around
the back of the phone.  Try to find where it works best.  The phone
manufacturers are notorius for paying little attention to the NFC antenna
they put on their products.  For example, I have a Samsung S5 next to me
and it seems to work best around the center of the phone.  I've used others
where I had to use the upper-left or upper-right corner of the phone.

Mark
