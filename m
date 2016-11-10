From: Barry Day <briselec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] rtl8xxxu: Fix for bogus data used to determine
 macpower
Date: Fri, 11 Nov 2016 08:45:37 +1000
Message-ID: <20161110224535.GA31931@testbox>
References: <CANf5e8aQ+HZz47M3-4+qjsG=ZCaXhBFU_jVupLqT4rEYT2LQFQ@mail.gmail.com>
 <wrfjh97i11vw.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <s.dave.jones-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
        John Heenan <john-AMlJbUfTsso@public.gmane.org>, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jes Sorensen <Jes.Sorensen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <wrfjh97i11vw.fsf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 08, 2016 at 09:29:07AM -0500, Jes Sorensen wrote:
> Dave Jones <s.dave.jones-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
> > On Fri, Nov 04, 2016 at 09:56:00AM -0400, Jes Sorensen wrote:
> >>
> >> Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> writes:
> >> > On Sun, 2016-10-30 at 19:02 -0400, Jes Sorensen wrote:
> >> >> Code is 80 characters wide, and comments are /* */ never the ugly C++
> >> >> crap.
> >> >
> >> > You might look at the recent Linus Torvalds authored commit
> >> > 5e467652ffef (?printk: re-organize log_output() to be more legible")
> >> > which does both of those: c99 // comments and > 80 columns.
> >> >
> >> > Absolutes are for zealots.
> >>
> >> What Linus does in his code, is totally up to him. What I pull into the
> >> driver that *I* maintain, is up to me. It is perfectly normal to expect
> >> submitters to respect the coding style of the piece of code they are
> >> trying to edit.
> >
> > Bullshit.  It's perfectly normal to respect Linux coding style described in
> > Documentation/CodingStyle.  Now let's back to the topic, could you
> > apply John's patch or you just wanna improve your driver is 100% bug free?
> 
> First of all, I call for proper CodingStyle to be applied to my driver,
> and I expect someone posting a patch to respect the codingstyle of the
> driver in question. It is simple respect for the code. If you consider
> that BS - that is on you!
> 
> Second I am NOT applying that patch as I have stated repeatedly because
> I am not convinced it is safe to do so and it changes the code flow for
> one type of chip and not the rest. In addition it uses a broken approach
> to doing chip specific changes.
> 
> In short, the patch is broken!
> 
> Jes


Jes is correct not to accept the patch. It is just a hack that in one
particular situation gets around a problem with the driver. It doesn't do
anything towards fixing the issue.

Barry
