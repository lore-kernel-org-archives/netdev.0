From: Greentime Hu <green.hu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4] net: ethernet: faraday: To support device tree usage.
Date: Wed, 8 Feb 2017 19:59:50 +0800
Message-ID: <CAEbi=3fZddPR8L+B6gW+yUraAK_wu=4oOyk3ff-Ez-Qy-LEBfQ@mail.gmail.com>
References: <20170124084606.GA11764@app09> <20170125.123448.742815192519658537.davem@davemloft.net>
 <CAK8P3a2Zr6=4x8JRa313DQ2ND0V=8eL0yKkrd93wbdxkiOtmSw@mail.gmail.com> <20170127221733.tcoudehkp5b5jnfw@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Networking <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170127221733.tcoudehkp5b5jnfw@rob-hp-laptop>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 28, 2017 at 6:17 AM, Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>
> On Wed, Jan 25, 2017 at 10:09:20PM +0100, Arnd Bergmann wrote:
> > On Wed, Jan 25, 2017 at 6:34 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> > > From: Greentime Hu <green.hu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > > Date: Tue, 24 Jan 2017 16:46:14 +0800
> > >> We also use the same binding document to describe the same faraday ethernet
> > >> controller and add faraday to vendor-prefixes.txt.
> > >
> > > Why are you renaming the MOXA binding file instead of adding a completely new one
> > > for faraday?  The MOXA one should stick around, I don't see a justification for
> > > removing it.
> >
> > This was my suggestion, basically fixing the name of the existing
> > binding, which was
> > accidentally named after one of the users rather than the company that did the
> > hardware.
> >
> > We can't change the compatible string, but I'd much prefer having only
> > one binding
> > file for this device rather than two separate ones that could possibly become
> > incompatible in case we add new properties to them. If there is only
> > one of them,
> > naming it according to the hardware design is the general policy.
> >
> > Note that we currently have two separate device drivers, but that is more a
> > historic artifact, and if we ever get around to merging them into one driver,
> > that should not impact the binding.
>
> The change is fine with me, but the subject and commit message need some
> work.

Hi, Rob:

Would you please advise me of the proper subject and commit messages?
Thanks~
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
