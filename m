From: "Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>
Subject: RE: pktgen problem (skb refcount) in 2.6.12-rc1
Date: Mon, 4 Apr 2005 10:26:18 -0700
Message-ID: <9D602ABCE51B0B488BF857A4787939B5042E7396@orsmsx410>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Harald Welte" <laforge@gnumonks.org>,
        "Robert Olsson" <Robert.Olsson@data.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Harald,

> 
> As for e1000 and or generic TX path changes, I don't have the time to
> review them now, sorry :(  That's why I posted it to netdev, to let
> people who have an idea about the committed changes know that there is
> an issue.
>

What version of e1000 you are using? 
If you are using e1000 5.7.6-k2 and haven't tried older versions, Could
you please try e1000 version 5.6.10.1-k2 (available in kernel 2.6.11)
and inform us the result?

Thanks,
Ayyappan V.

> -----Original Message-----
> From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com] On
> Behalf Of Harald Welte
> Sent: Sunday, April 03, 2005 10:27 PM
> To: Robert Olsson
> Cc: netdev@oss.sgi.com
> Subject: Re: pktgen problem (skb refcount) in 2.6.12-rc1
> 
> On Sun, Apr 03, 2005 at 09:18:30PM +0200, Robert Olsson wrote:
> 
> >  > I've tried to track the problem down, and I've confirmed that
skb-
> >users
> >  > never goes down to 1 but instead stays at '2'.
> >
> >  > The same system with the same pktgen script works fine with
2.6.11.6.
> >  >
> >  > I'm reporting this since it seems like it sounds like we have a
skb
> >  > usage count leak somewhere :(
> >
> >  Sounds like a diff could give some clues. pktgen, e1000 and TX-path
> should
> >  be interesting as ev. changes in kernel config.
> 
> no changes in kernel config.  I've reviewed pktgen changes and
couldn't
> find something that would cause the problem.  It always only
> atomic_inc'ed the ussage cound (and decrements only in error path)
which
> is perfectly fine.
> 
> As for e1000 and or generic TX path changes, I don't have the time to
> review them now, sorry :(  That's why I posted it to netdev, to let
> people who have an idea about the committed changes know that there is
> an issue.
> 
> Cheers,
> 	Harald
> --
> - Harald Welte <laforge@gnumonks.org>
> http://gnumonks.org/
>
========================================================================
==
> ==
> "Privacy in residential applications is a desirable marketing option."
>                                                   (ETSI EN 300 175-7
Ch.
> A6)
