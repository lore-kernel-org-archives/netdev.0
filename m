From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 v2] route: label externally offloaded routes
Date: Tue, 24 Mar 2015 20:33:33 -0400
Message-ID: <20150325003332.GA1051@gospo>
References: <1426447894-41398-1-git-send-email-sfeldma@gmail.com>
 <20150316131805.GF12614@gospo.home.greyhouse.net>
 <CAE4R7bC7JPPL2ak0e=qUs3YGhdt81tq1v66+4pDy-bFERXnUyw@mail.gmail.com>
 <20150317132456.GG12614@gospo.home.greyhouse.net>
 <20150317134921.GE2036@nanopsycho.lan>
 <20150317191557.GB18165@gospo.home.greyhouse.net>
 <20150324155137.03671191@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jeff Kirsher <tarbal@gmail.com>,
	John Linville <linville@tuxdriver.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f43.google.com ([209.85.213.43]:35057 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbbCYAdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 20:33:40 -0400
Received: by yhim52 with SMTP id m52so4771069yhi.2
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 17:33:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150324155137.03671191@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2015 at 03:51:37PM -0700, Stephen Hemminger wrote:
jG> On Tue, 17 Mar 2015 15:15:57 -0400
> Andy Gospodarek <gospo@cumulusnetworks.com> wrote:
> 
> > On Tue, Mar 17, 2015 at 02:49:21PM +0100, Jiri Pirko wrote:
> > > Tue, Mar 17, 2015 at 02:24:56PM CET, gospo@cumulusnetworks.com wrote:
> > > >On Mon, Mar 16, 2015 at 09:14:50PM -0700, Scott Feldman wrote:
> > > >> On Mon, Mar 16, 2015 at 6:18 AM, Andy Gospodarek
> > > >> <gospo@cumulusnetworks.com> wrote:
> > > >> > On Sun, Mar 15, 2015 at 12:31:34PM -0700, sfeldma@gmail.com wrote:
> > > >> >> From: Scott Feldman <sfeldma@gmail.com>
> > > >> >>
> > > >> >> v2:
> > > >> >>
> > > >> >> No clear outcome on polling for choices of "external", "offload", "hw", or
> > > >> >> "hardware".  Andy's concern about "external" being confusing for users is
> > > >> >> valid.  So, I'm making executive decision to use "external_offload" for label,
> > > >> >> as suggested by Jiri.
> > > >> >
> > > >> > This seems like quite a mouthful.  Just make it 'offload' or 'hardware'
> > > >> > so the output of 'ip route show' isn't so long that it will frequently
> > > >> > be longer than 80 chars.  Being longer than 80 chars is going to be
> > > >> > irritating for _many_ users.
> > > >> 
> > > >> Andy, since you have passion on this topic, would you mind taking it
> > > >> from here to get consensus, and post an updated patch, if needed?
> > > >
> > > >Absolutely.  I felt bad responding with more complaints yesterday
> > > >without proposing an alternative patch.
> > > >
> > > >I'll be happy to handle this -- it will elimininate at least one
> > > >complainer!
> > > >
> > > >
> > > >> I was about to suggest a new made-up work like "keroff" and someday
> > > >> the new word is added to Websters .  Daddy, what's "keroff"?  Oh son,
> > > >> that means "offloaded from kernel to external device".  Ya, actually,
> > > >> that's my vote: keroff.
> > > 
> > > Hmm, on the second thought, shouldn't it be rather "extoff" ?
> > > 
> > 
> > I'm really liking the sound of 'extoffk'  ;)
> > 
> 
> I am bouncing this patch, come back when you decide on a name.

Based on the polling I did, the concensus was that people preferred to
use the string 'offload' to describe these entries.  I'll submit the
patch I had prepared now.
