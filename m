From: Kyle Moffett <kyle@moffetthome.net>
Subject: Re: [PATCH 2/2] sky2: Add unidirectional fiber link support
Date: Sat, 28 Aug 2010 01:35:19 -0400
Message-ID: <AANLkTi=BfgD+fFXZMAzz0OAuj46X0dxThTSSB9OmCg-3@mail.gmail.com>
References: <1282938138-17844-1-git-send-email-Kyle.D.Moffett@boeing.com>
 <20100827133825.494b8098@nehalam> <81DAD951-0909-4D3A-8451-AEE3F9B07054@boeing.com>
 <20100827142217.5fccc098@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Moffett, Kyle D" <Kyle.D.Moffett@boeing.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:45510 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783Ab0H1Ffk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 01:35:40 -0400
In-Reply-To: <20100827142217.5fccc098@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 27, 2010 at 17:22, Stephen Hemminger
<shemminger@linux-foundation.org> wrote:
> On Fri, 27 Aug 2010 15:51:58 -0500 "Moffett, Kyle D" <Kyle.D.Moffett@boeing.com> wrote:
>> Do you have any comments or criticisms of the particular "duplex" method of configuring the unidirectional link support?
>
> No that is fine, but the FIB doesn't really understand RX only links so I expect users will do stupid things.

As far as the chipset is concerned, an "rxonly" link would just be a
regular full-duplex forced-mode fiber link.  If the user happens to
wire up the "transmit" path on such a link and is then surprised when
the driver is actually able to use that path, that would seem to be
their own problem.  I'm considering perhaps fiddling with ARP or
routing behavior over txonly/rxonly links, so I'd like to preserve the
symmetry even if just for documentation purposes or future
optimizations.

When I get any applicable review commentary sorted out and worked
through, in whose tree should I request inclusion of these 2 patches?
Thanks for your comments!

Cheers,
Kyle Moffett
