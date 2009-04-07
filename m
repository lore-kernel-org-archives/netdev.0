From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.29-git13: Reported regressions from 2.6.28
Date: Mon, 6 Apr 2009 21:07:24 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904062103531.4010@localhost.localdomain>
References: <n4io5wq70ZO.A.gzG.rFn2JB@chimera>
	<alpine.LFD.2.00.0904061443000.7443@localhost.localdomain>
	<9b1675090904062056v235af58ehc99cce8ff97fe501@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>,
        Linux SCSI List <linux-scsi@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Natalie Protasevich <protasnb@gmail.com>,
        Linux ACPI <linux-acpi@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kernel Testers List <kernel-testers@vger.kernel.org>,
        Linux PM List <linux-pm@lists.linux-foundation.org>
To: "Trenton D. Adams" <trenton.d.adams@gmail.com>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
In-Reply-To: <9b1675090904062056v235af58ehc99cce8ff97fe501@mail.gmail.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org



On Mon, 6 Apr 2009, Trenton D. Adams wrote:
> >
> > This went through bisection, but looking at the email log, I tend to
> > suspect that maybe Trenton marked some versions good even though they
> > weren't (because they got versions numbers from v2.6.27), and didn't
> > realize that that messes up bisection in a big way.
> 
> Is it appropriate for me to respond to these things?

Yes. I added you to the cc exactly because it was hard for me to judge 
from the email discussion that is linked to in the regression list whether 
you actually _did_ mark some versions good because of confusion about the 
version numbering.

That would certainly explain why bisection didn't seem to work.

But it's not the _only_ reason bisection doesn't work. Sometimes you can 
be as careful as possible, but if it's a bug that is even _slightly_ flaky 
(timing-dependencies etc), and the bisection marked something good that 
shouldn't have been (or vice versa, but that's unusual), then the 
bisection end result won't be right.

So you may well have done everything right, and I'm not trying to blame 
you. I just was hoping that maybe that confusion would explain why the 
bisection didn't seem to pinpoint anything sane..

> I was wondering about that.  Someone had mentioned that I should trust
> the bisect, even when it takes me into "other versions", and it was
> taking me through 2.6.27, which I thought was just really weird.
> Would you like me to try the bisect again with a little more
> diligence, or do you think it can be found with the info given?  It
> may take a week or so, due to being a bit busy.

It would be good, especially if this bug doesn't end up being solved some 
other way... And slow results are better than no results at all ;)

			Linus
