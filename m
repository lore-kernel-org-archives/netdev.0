From: jamal <hadi@cyberus.ca>
Subject: Re: TODO list before feature freeze
Date: Tue, 30 Jul 2002 08:04:42 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0207300800440.15727-100000@shell.cyberus.ca>
References: <20020729224724.91A3A4B7F@lists.samba.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netfilter-devel@lists.netfilter.org>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <20020729224724.91A3A4B7F@lists.samba.org>
List-Id: netdev.vger.kernel.org



On Tue, 30 Jul 2002, Rusty Russell wrote:

> In message <Pine.GSO.4.30.0207290648020.12604-100000@shell.cyberus.ca> you writ
> e:
> > > Connection tracking:
> >
> > Fix perfomance problems with this thing. You may have seen reports of
> > performance degradation it introduces. I was hoping to take a look at some
> > point time hasnt been visiting this side.
>
> There are several simple things to do here.  One is to improve the
> hashing (fine for internet traffic, but frequently sucks under LAN
> conditions), which is easy.  The other is to modify the
> one-timer-per-connection approach to a "sweep once a second, or when
> full" approach.
>

Thats the right direction. From code inspection, fixing the later problem
would give you a lot more punch.

> Both these are simple patches, but I want to see benchmarks showing
> that they improve things.
>

Indeed.

> Yes, that's exactly the plan.  It'd be more like the old-style
> insert/delete (probably not replace), except with a "commit"
> interface, implemented by copying the rules when they start modifying.
>

Why not take a look at the way tc does things and emulate that?

cheers,
jamal
