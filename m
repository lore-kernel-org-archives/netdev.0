From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing
 cgroup path
Date: Mon, 21 Apr 2014 11:03:07 -0400
Message-ID: <20140421150307.GA4367@redhat.com>
References: <CALCETrXj6kD3E+vsaWmkrSbaQYTu=c-Hsw640jh4O+FbojYk2g@mail.gmail.com>
 <20140417171256.GB25334@redhat.com>
 <CALCETrVq4HRpfWOAbZAQbyjuraQd=OxnW=WjSoe5JgBzRStiKg@mail.gmail.com>
 <1397756025.2628.64.camel@willson.li.ssimo.org>
 <CALCETrVBJFgKwRKBE2jAG6kiGgkJ+MyQiw2nyz5yj0h68kCk9A@mail.gmail.com>
 <1397759013.2628.86.camel@willson.li.ssimo.org>
 <20140417185023.GA32527@redhat.com>
 <1397761817.2628.113.camel@willson.li.ssimo.org>
 <20140417191646.GA2461@redhat.com>
 <CALCETrW3F1+3qF3thrAmuoWVbRveBJ2=owpigh4mv6iAafoQCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALCETrW3F1+3qF3thrAmuoWVbRveBJ2=owpigh4mv6iAafoQCw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 17, 2014 at 12:46:22PM -0700, Andy Lutomirski wrote:
> On Thu, Apr 17, 2014 at 12:16 PM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > On Thu, Apr 17, 2014 at 03:10:17PM -0400, Simo Sorce wrote:
> >
> > [..]
> >> At this point I think journald people need to give a little bit more
> >> details on how they plan to use SO_PASSCGROUP.
> >>
> >> For my use cases I care only about streams and SO_PEERCGROUP that does
> >> not have any of the (perceived) issues of SO_PASSCGROUP.
> >
> > Ok, so we agree that SO_PEERCGROUP is not a problem. And it solves the
> > problem for some of the use cases.
> >
> > And there is lot of contention on the SO_PASSCGROUP option.
> >
> > So how about taking one step at a time. Get SO_PEERCGROUP in first and
> > then get into more details on how SO_PASSCGROUP will exactly be used and
> > then decide what to do.
> 
> My only objection to SO_PEERCGROUP is that I don't believe that a
> legitimate use case exists.  I think the feature itself is safe to
> add.

So what happened to logger use case where logger accepts stream
connections and logs the cgroup of client too.

W.r.t systemd, looks like journald is accepting connections at
/run/systemd/journal/stdout. (stdout_stream_new() and
server_open_stdout_socket()).

Thanks
Vivek
