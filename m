From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 v2] route: label externally offloaded routes
Date: Tue, 17 Mar 2015 09:24:56 -0400
Message-ID: <20150317132456.GG12614@gospo.home.greyhouse.net>
References: <1426447894-41398-1-git-send-email-sfeldma@gmail.com>
 <20150316131805.GF12614@gospo.home.greyhouse.net>
 <CAE4R7bC7JPPL2ak0e=qUs3YGhdt81tq1v66+4pDy-bFERXnUyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	=?utf-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jeff Kirsher <tarbal@gmail.com>,
	John Linville <linville@tuxdriver.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:35261 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520AbbCQNZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 09:25:01 -0400
Received: by ykfs63 with SMTP id s63so3589794ykf.2
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 06:25:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bC7JPPL2ak0e=qUs3YGhdt81tq1v66+4pDy-bFERXnUyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2015 at 09:14:50PM -0700, Scott Feldman wrote:
> On Mon, Mar 16, 2015 at 6:18 AM, Andy Gospodarek
> <gospo@cumulusnetworks.com> wrote:
> > On Sun, Mar 15, 2015 at 12:31:34PM -0700, sfeldma@gmail.com wrote:
> >> From: Scott Feldman <sfeldma@gmail.com>
> >>
> >> v2:
> >>
> >> No clear outcome on polling for choices of "external", "offload", "hw", or
> >> "hardware".  Andy's concern about "external" being confusing for users is
> >> valid.  So, I'm making executive decision to use "external_offload" for label,
> >> as suggested by Jiri.
> >
> > This seems like quite a mouthful.  Just make it 'offload' or 'hardware'
> > so the output of 'ip route show' isn't so long that it will frequently
> > be longer than 80 chars.  Being longer than 80 chars is going to be
> > irritating for _many_ users.
> 
> Andy, since you have passion on this topic, would you mind taking it
> from here to get consensus, and post an updated patch, if needed?

Absolutely.  I felt bad responding with more complaints yesterday
without proposing an alternative patch.

I'll be happy to handle this -- it will elimininate at least one
complainer!


> I was about to suggest a new made-up work like "keroff" and someday
> the new word is added to Websters .  Daddy, what's "keroff"?  Oh son,
> that means "offloaded from kernel to external device".  Ya, actually,
> that's my vote: keroff.

Bless you!
