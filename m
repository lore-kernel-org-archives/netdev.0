From: John Linn <John.Linn@xilinx.com>
Subject: RE: [PATCH 2/2] net: ll_temac: fix checksum offload logic
Date: Thu, 27 May 2010 07:26:00 -0600
Message-ID: <4d2d980b-53f6-457a-b4ef-b1bf82f95138@VA3EHSMHS017.ehs.local>
References: <1274894959-27473-1-git-send-email-john.linn@xilinx.com><0690e798-1e5e-4416-90dc-04a9df16600f@SG2EHSMHS005.ehs.local> <20100526.204517.35032653.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	<grant.likely@secretlab.ca>, <jwboyer@linux.vnet.ibm.com>,
	<john.williams@petalogix.com>, <michal.simek@petalogix.com>,
	"Brian Hill" <bhill@xilinx.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-va3.bigfish.com ([216.32.180.114]:42655 "EHLO
	mail185-va3-R.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756689Ab0E0N2B convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 May 2010 09:28:01 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <20100526.204517.35032653.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, May 26, 2010 9:45 PM
> To: John Linn
> Cc: netdev@vger.kernel.org; linuxppc-dev@ozlabs.org;
grant.likely@secretlab.ca;
> jwboyer@linux.vnet.ibm.com; john.williams@petalogix.com;
michal.simek@petalogix.com; Brian Hill
> Subject: Re: [PATCH 2/2] net: ll_temac: fix checksum offload logic
> 
> aFrom: John Linn <john.linn@xilinx.com>
> Date: Wed, 26 May 2010 11:29:19 -0600
> 
> > The current checksum offload code does not work and this corrects
> > that functionality. It also updates the interrupt coallescing
> > initialization so than there are fewer interrupts and performance
> > is increased.
> >
> > Signed-off-by: Brian Hill <brian.hill@xilinx.com>
> > Signed-off-by: John Linn <john.linn@xilinx.com>
> 
> Applied, although I changed "temac_features" to be explicitly
> "unsigned int" instead of just plain "unsigned"

Awesome! Appreciate the help with both patches David.

> 


This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


