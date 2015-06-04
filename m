From: Pavel Simerda <psimerda@redhat.com>
Subject: Re: [PATCH iproute2] tipc: introduce TIPC configuration tool
Date: Thu, 4 Jun 2015 13:30:43 -0400 (EDT)
Message-ID: <423324682.6031901.1433439043244.JavaMail.zimbra@redhat.com>
References: <1431004056-6282-1-git-send-email-richard.alpe@ericsson.com> <20150521144340.1b112c0a@urahara> <1689829731.5883859.1433413415372.JavaMail.zimbra@redhat.com> <5570393F.9060401@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: Richard Alpe <richard.alpe@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:46535 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536AbbFDRa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 13:30:56 -0400
In-Reply-To: <5570393F.9060401@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Original Message -----
> From: "Richard Alpe" <richard.alpe@ericsson.com>
> To: "Pavel Simerda" <psimerda@redhat.com>, "Stephen Hemminger" <stephen@networkplumber.org>
> Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
> Sent: Thursday, June 4, 2015 1:40:47 PM
> Subject: Re: [PATCH iproute2] tipc: introduce TIPC configuration tool
> 
> On 2015-06-04 12:23, Pavel Simerda wrote:
> > ----- Original Message -----
> >> From: "Stephen Hemminger" <stephen@networkplumber.org>
> >> To: "richard alpe" <richard.alpe@ericsson.com>
> >> Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
> >> Sent: Thursday, May 21, 2015 11:43:40 PM
> >> Subject: Re: [PATCH iproute2] tipc: introduce TIPC configuration tool
> >>
> >> On Thu, 7 May 2015 15:07:35 +0200
> >> <richard.alpe@ericsson.com> wrote:
> >>
> >>> From: Richard Alpe <richard.alpe@ericsson.com>
> >>>
> >>> This is the new tipc tool that utilizes the relativly new TIPC netlink
> >>> API
> >>> in
> >>> the kernel. Introducing this tool into iproute2 has been discussed
> >>> previously.
> >>>
> >>> For more information about the design decisions of this tool, see the
> >>> README
> >>> file.
> >>>
> >>> There isn't yet a manpage for the this tool. I will start to write one
> >>> once
> >>> I
> >>> submitted this for review.
> >>>
> >>> Richard Alpe (1):
> >>>   tipc: add new TIPC configuration tool
> >>
> >> I went ahead and merged this.
> >> It does add dependency on libmnl which the distribution maintainers will
> >> have
> >> to add to their stuff.
> > 
> > Does the new dependency suggest the whole iproute2 is moving to libmnl?
> That is what I was told and the reason I wrote "tipc" based on libmnl.
> 
> Regards
> Richard

That is great news, I was at first afraid that it was a random decision limited
to tipc. Is there any plan for the move? I might just as well participate. Also
I found out that some things are done using ioctl instead of netlink,
especially in ip-tunnel. I'd happily be part of a larger scale iproute2 cleanup.

Cheers,

Pavel

> > Or is
> > there a good reason to use an external netlink library as well as an
> > internal one?
> > 
> > Cheers,
> > 
> > Pavel
> > 
> >>
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe netdev" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
> 
> 
