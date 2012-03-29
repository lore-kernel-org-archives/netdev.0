From: Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] f_phonet: fix skb truesize underestimation
Date: Wed, 28 Mar 2012 22:15:01 -0400
Message-ID: <CAP=VYLpMZn9WrCExDiY9iis7nvao6kxiLe0EXgeHk0onnNUd+w@mail.gmail.com>
References: <1332853442.3248.15.camel@edumazet-laptop>
	<20120327.225109.752822925052179338.davem@davemloft.net>
	<20120328085535.GF18156@arwen.pp.htv.fi>
	<20120328.053310.219141897175161116.davem@davemloft.net>
	<20120328124314.GG28319@arwen.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org
To: balbi-l0cyMroinI0@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120328124314.GG28319-S8G//mZuvNWo5Im9Ml3/Zg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 28, 2012 at 8:43 AM, Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org> wrote:
> On Wed, Mar 28, 2012 at 05:33:10AM -0400, David Miller wrote:
>> From: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
>> Date: Wed, 28 Mar 2012 11:55:36 +0300
>>
>> > On Tue, Mar 27, 2012 at 10:51:09PM -0400, David Miller wrote:
>> >> From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> >> Date: Tue, 27 Mar 2012 06:04:02 -0700
>> >>
>> >> > Now skb_add_rx_frag() has a truesize parameter, we can fix f_phonet to
>> >> > properly account truesize of each fragment : a full page.
>> >> >
>> >> > Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> >>
>> >> Applied.
>> >
>> > did you apply both patches ?
>>
>> You never need to ask me these kinds of questions, you can
>> either check my GIT tree or look at:
>>
>> http://patchwork.ozlabs.org/project/netdev/list/?state=3
>
> I'm asking because drivers/usb/gadget/ should either go through me or
> you should wait for my Acked-by. Now it's too late for that, but next
> time for my Ack.

Hi Felipe,

Being in the MAINTAINERS file is best interpreted as "I care about
this driver/code/subsystem, and I'll do my best to fix/integrate for it,
and I want to know about changes to it".

It has never meant that all patches to that MAINTAINER's code must
be OK'd by that one particular maintainer before being committed.

In the last twenty years, I can't ever recall any one driver/subsystem
where one individual had the ultimate veto (excluding Linus).  And
that is a good thing.

If a commit has dependencies to low level skb accounting, then it
makes perfect sense for it to be in the tree where those accounting
changes are made.  Even more sense for it to be done by the
people who know those internals better than anyone else.

Speaking for myself, if I had networking code that Eric and Dave
made changes to, I'd be pretty damn happy that smarter people
than myself did the changes for me, and that they were nice enough
to have CC'd me on the changes as a courtesy.

Just my $0.02.
Paul.

>
> --
> balbi
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
