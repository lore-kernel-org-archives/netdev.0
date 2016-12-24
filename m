From: Mark Greer <mgreer-luAo+O/VEmrlveNOaEYElw@public.gmane.org>
Subject: Re: [PATCH v3 3/3] nfc: trf7970a: Prevent repeated polling from
 crashing the kernel
Date: Sat, 24 Dec 2016 10:24:39 -0700
Message-ID: <20161224172439.GA15103@animalcreek.com>
References: <1482380314-16440-1-git-send-email-geoff@kuvee.com>
 <1482380314-16440-3-git-send-email-geoff@kuvee.com>
 <20161224060141.GA9069@animalcreek.com>
 <CAO7Z3W+n85jbr8cmj3HJV1c+eL=oRh-XRy+O=iZ+mD=ov2WABA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
        Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
        Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Justin Bronder <justin-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>,
        Jaret Cantu <jaret.cantu-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>
To: Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAO7Z3W+n85jbr8cmj3HJV1c+eL=oRh-XRy+O=iZ+mD=ov2WABA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 24, 2016 at 11:17:18AM -0500, Geoff Lansberry wrote:
> Mark - I'm sorry, but I did not write this code, and therefore was not
> able to accurately describe it.   It is fixing a different issue, not
> the neard segfault that we are still chasing. Last week Jaret Cantu
> sent a separate email explaining the purpose of the code, which had
> you copied, did you see that?

Hm, no, I didn't.  I received an email from Justin Bronder but not from
Jaret Cantu.  Justin's email did help but is still pretty high-level.
We need a clear understanding as to what is happening in the digital
layer and the driver to know how execution is getting into a block of
error handling code that should never be executed.  Once we understand
that we can start thinking about what the best fix is.

> Does it explain why it was done to
> your satisfaction?   I've asked him to join in on the effort to push
> the change upstream, however he will not be available until the new
> year.

I expect that it would help if he joins.  After the holidays is fine -
I think many people are taking it easy for the next week or so, anyway.

> I know you did suggest that we split off that change from the others,
> and if now is the time to do that, let me know.   If you don't have
> the email from Jaret, also please let me know and I will forward it to
> you.

I think it would help you if you split it off because the first two patches
have a good chance of being accepted but this one doesn't (yet).  If you
separate the them, it will make it easier for Samuel to take the first two
(or he may take the first two anyway but its always good to make it as
easy maintainers as you can).

Mark
--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
