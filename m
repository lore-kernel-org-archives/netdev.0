From: Mark Greer <mgreer@animalcreek.com>
Subject: Re: [PATCH v3 3/3] nfc: trf7970a: Prevent repeated polling from
 crashing the kernel
Date: Tue, 3 Jan 2017 09:33:24 -0700
Message-ID: <20170103163324.GA3184@animalcreek.com>
References: <1482380314-16440-1-git-send-email-geoff@kuvee.com>
 <1482380314-16440-3-git-send-email-geoff@kuvee.com>
 <20161224060141.GA9069@animalcreek.com>
 <CAO7Z3W+n85jbr8cmj3HJV1c+eL=oRh-XRy+O=iZ+mD=ov2WABA@mail.gmail.com>
 <20161224172439.GA15103@animalcreek.com>
 <CAO7Z3WJa0goJ-VXc7dvyz8imZtqby6QsC0QNH+uRAE8LhxqU2w@mail.gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAO7Z3WJa0goJ-VXc7dvyz8imZtqby6QsC0QNH+uRAE8LhxqU2w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Please stop top-posting.  Bottom-post only to these lists.]

Hi Geoff & happy new year.

On Tue, Dec 27, 2016 at 09:18:32AM -0500, Geoff Lansberry wrote:
> Mark - I will split this off soon.

OK

> In the meantime - here is some more info about how we use it.
> 
> We do use NFC structures.    I did find an interesting clue in that
> there are certain bottles that cause neard to segfault,  I'm not sure
> what is different about them.  We write a string, like
> "coppola_chardonnay_2015" to the bottles.

Off the top of my head, it could be the length of the text.
It would be useful to compare the data that works to the data
that doesn't work.  Can you install NXP's 'TagInfo' app on a
smartphone and scan tags with working & non-working data?
You can email the data from the app to yourself, edit out
the cruft, and share here.

> Come to think of it, I
> haven't done anything special to make that an ndef record, just
> assumed that it would happen by default, I'll look into this further.

If you wrote the data using neard, it will be NDEF formatted.
Since it is working this well, it is virtually guaranteed that
the data is NDEF formatted.

>   Also, I've been running neard with --plugin nfctype2. Just in case
> the problem was happening due to cycling through other tag types.   It
> didn't seem to make any difference, but I have not gone back to
> default.

Good to know, thanks.

Mark
--
