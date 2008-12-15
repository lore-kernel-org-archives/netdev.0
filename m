From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: Re: bnx2x machine check in bnx2x_ack_int()
Date: Mon, 15 Dec 2008 09:21:08 -0700
Message-ID: <200812150921.08668.bjorn.helgaas@hp.com>
References: <200812091204.35296.bjorn.helgaas@hp.com> <1229328209.22295.16.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eilon Greenstein" <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:15373 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113AbYLOQVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 11:21:12 -0500
In-Reply-To: <1229328209.22295.16.camel@lb-tlvb-eliezer>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 15 December 2008 01:03:29 am Eilon Greenstein wrote:
> My sincere apologize for the late response. When searching the mailing
> list to see if I accidentally missed your reply, I have come to realize
> that my response was never sent (problem with my email client).

No problem, thanks for the response!

> On Tue, 2008-12-09 at 11:04 -0800, Bjorn Helgaas wrote:
> > Hi Eilon,
> > 
> > I'm using bnx2x 1.45.23 from RHEL5.3s4 on a prototype ia64 platform,
> > and I see intermittent machine checks at bnx2x_ack_int+176, which is
> > just after __ia64_readl() returns.
> I see that you are using two 57710 chips. What kind of board are you
> using (which PHY)?

This is a blade with separate PHYs.  In this case, there is no PHY
at all because the module that would contain the PHY is not installed.

> > This is a proto with incomplete firmware, and the driver correctly
> > complains about that, but it seems like there's still a hole where
> > things blow up.
> If you set the right FW on the board, do you still see the problem? I'm
> asking to determine if this is a problem specific to the "no FW" case or
> general issue with this configuration

I'm trying to get FW installed, but haven't had any luck yet.

> > The machine check happens intermittently on boot, but I can reproduce
> > it instantly with a loop like this:
> > 
> >   # while /bin/true; do ifup eth6; date; done
> > 
> > Here's some lspci and dmesg information.  I added a little debug in
> > bnx2x_ack_int(), so this is a kernel I compiled myself.
> > 
> > Let me know if there's any information I can collect or testing I
> > can do.
> Unfortunately, with the 57711 Mezzanine on the IA64 blade that I have, I
> cannot reproduce this failure, so I will probably need more information.
> Can you please send me the nvram content?

Sure.  Is there an easy way to collect this, or should I instrument the
driver to print it out or something?

Bjorn
