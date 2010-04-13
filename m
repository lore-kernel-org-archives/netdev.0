From: John Linn <John.Linn@xilinx.com>
Subject: RE: [PATCH 2/2] [V5] Add non-Virtex5 support for LL TEMAC driver
Date: Tue, 13 Apr 2010 08:43:09 -0600
Message-ID: <9d7342a6-0819-4cf1-941c-d397ca02d5a0@VA3EHSMHS036.ehs.local>
References: <1270746482-29914-1-git-send-email-john.linn@xilinx.com><960dddba-8a63-4480-8245-f06fad59ab36@SG2EHSMHS005.ehs.local><x2sfa686aa41004091110l87cd2234rc68906080fc4fe03@mail.gmail.com> <20100413.013403.184052247.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	<jwboyer@linux.vnet.ibm.com>, <eric.dumazet@gmail.com>,
	<john.williams@petalogix.com>, <michal.simek@petalogix.com>,
	<jtyner@cs.ucr.edu>
To: "David Miller" <davem@davemloft.net>, <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe005.messaging.microsoft.com ([216.32.180.15]:5988 "EHLO
	VA3EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751642Ab0DMOnh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Apr 2010 10:43:37 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <20100413.013403.184052247.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, April 13, 2010 2:34 AM
> To: grant.likely@secretlab.ca
> Cc: John Linn; netdev@vger.kernel.org; linuxppc-dev@ozlabs.org;
jwboyer@linux.vnet.ibm.com;
> eric.dumazet@gmail.com; john.williams@petalogix.com;
michal.simek@petalogix.com; jtyner@cs.ucr.edu
> Subject: Re: [PATCH 2/2] [V5] Add non-Virtex5 support for LL TEMAC
driver
> 
> From: Grant Likely <grant.likely@secretlab.ca>
> Date: Fri, 9 Apr 2010 12:10:21 -0
> 
> > On Thu, Apr 8, 2010 at 11:08 AM, John Linn <john.linn@xilinx.com>
wrote:
> >> This patch adds support for using the LL TEMAC Ethernet driver on
> >> non-Virtex 5 platforms by adding support for accessing the Soft DMA
> >> registers as if they were memory mapped instead of solely through
the
> >> DCR's (available on the Virtex 5).
> >>
> >> The patch also updates the driver so that it runs on the
MicroBlaze.
> >> The changes were tested on the PowerPC 440, PowerPC 405, and the
> >> MicroBlaze platforms.
> >>
> >> Signed-off-by: John Tyner <jtyner@cs.ucr.edu>
> >> Signed-off-by: John Linn <john.linn@xilinx.com>
> >
> > Picked up and build tested both patches on 405, 440, 60x and ppc64.
> > No build problems found either built-in or as a module.
> >
> > for both:
> > Acked-by: Grant Likely <grant.likely@secretlab.ca>
> 
> Ok, both applied to net-next-2.6, thanks everyone for sorting this
> out.

Great! Thanks David, appreciate the help.

This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


