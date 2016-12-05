From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2 1/1] tc: updated man page to reflect handle-id
 use in filter GET command.
Date: Mon, 5 Dec 2016 12:07:20 +0100
Message-ID: <20161205110720.GL21576@orbyte.nwl.cc>
References: <1480623644-27533-1-git-send-email-mrv@mojatatu.com>
 <20161202140622.5ecad2d6@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roman Mashak <mrv@mojatatu.com>, netdev@vger.kernel.org,
        sathya.perla@broadcom.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:48534 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750816AbcLELHX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 06:07:23 -0500
Content-Disposition: inline
In-Reply-To: <20161202140622.5ecad2d6@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2016 at 02:06:22PM -0800, Stephen Hemminger wrote:
> On Thu,  1 Dec 2016 15:20:44 -0500
> Roman Mashak <mrv@mojatatu.com> wrote:
> 
> > Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> > ---
> >  man/man8/tc.8 | 6 ++++--
> >  1 file changed, 4 insertions(+), 2 deletions(-)
> > 
> > diff --git a/man/man8/tc.8 b/man/man8/tc.8
> > index 8a47a2b..d957ffa 100644
> > --- a/man/man8/tc.8
> > +++ b/man/man8/tc.8
> > @@ -32,7 +32,9 @@ class-id ] qdisc
> >  DEV
> >  .B [ parent
> >  qdisc-id
> > -.B | root ] protocol
> > +.B | root ] [ handle
> > +handle-id ]
> > +.B protocol
> >  protocol
> >  .B prio
> >  priority filtertype
> > @@ -577,7 +579,7 @@ it is created.
> >  
> >  .TP
> >  get
> > -Displays a single filter given the interface, parent ID, priority, protocol and handle ID.
> > +Displays a single filter given the interface, qdisc-id, priority, protocol and handle-id.
> >  
> >  .TP
> >  show
> 
> The proper syntax for man page usage section is to put keywords in bold and any value
> that is variable in italic.
> 
> I know this whole man page doesn't do this correctly. But that doesn't mean that new
> additions should continue with the mistake.
> 
> Please revise and resubmit. Extra bonus points for fixing the other bits.

+1! Thanks for playing man page style Nazi^Wguardian. :)

Cheers, Phil
