From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Fri, 2 Dec 2005 23:49:28 +0100
Message-ID: <9a8748490512021449n3605b952jdc56eca5ffb6ec70@mail.gmail.com>
References: <200512022253.19029.a1426z@gawab.com>
	 <Pine.LNX.4.61.0512021527090.11277@chaos.analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Al Boldi <a1426z@gawab.com>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org,
	Linux kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750966AbVLBWtb@vger.kernel.org>
To: "linux-os (Dick Johnson)" <linux-os@analogic.com>
In-Reply-To: <Pine.LNX.4.61.0512021527090.11277@chaos.analogic.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/2/05, linux-os (Dick Johnson) <linux-os@analogic.com> wrote:
>
> On Fri, 2 Dec 2005, Al Boldi wrote:
>
> > The current ip / ifconfig configuration is arcane and inflexible.  The reason
> > being, that they are based on design principles inherited from the last
> > century.
> >
> > In a GNU/OpenSource environment, OpenMinds should not inhibit themselves
> > achieving new design-goals to enable a flexible non-redundant configuration.
> >
> > Specifically, '#> ip addr ' exhibits this issue clearly, by requiring to
> > associate the address to a link instead of the other way around.
> >
> > Consider this new approach for better address management:
> > 1. Allow the definition of an address pool
> > 2. Relate links to addresses
> > 3. Implement to make things backward-compatible.
> >
> > The obvious benefit here, would be the transparent ability for apps to bind
> > to addresses, regardless of the link existence.
> >
>
> A link needs to exist for it to have an address.
>

I'm only guessing since I'm not entirely sure what Mr. Boldi means,
but my guess is that he's proposing that an app can bind to an IP
address without that address being assigned to any currently available
interface and then later if that IP does get assigned to an interface
the app will start recieving traffic then. Also possibly allowing the
address to be removed from one interface and then later assigned to
another one without apps noticing.
I don't know /if/ that is what was meant, but that's how I read it.


> > Another benefit includes the ability to scale the link level transparently,
> > regardless of the application bind state.
> >
>
> That doesn't make any sense. Multiple applications can bind to the
> same address. Then can't bind to the same port because they won't
> get all their data.
>
> > And there may be many other benefits... (i.e. 100% OSI compliance)
> >
> What does Open Source Initiative have to do with this at all???
> You are just spewing stuff out.
>

I'm believe Mr. Boldi is refering to OSI as in Open Systems
Interconnection (http://en.wikipedia.org/wiki/OSI_model), not as in
Open Source Initiative.


> > --
> > Al
>
> Also, how does this involve the kernel? The interface to the kernel
> for hardware configuration is via ioctl(). For logic, sockets.
>
> If the user-level tools suck, then they should be fixed. It
> really doesn't have anything to do with the kernel.
>
> Cheers,
> Dick Johnson
>
[snip]
>
> Thank you.
>

--
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
