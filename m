From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Fri, 4 May 2007 13:43:43 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902CA58E7@orsmsx414.amr.corp.intel.com>
References: <20070504130110.0694aee6@freekitty>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <hadi@cyberus.ca>, "Patrick McHardy" <kaber@trash.net>,
	<netdev@vger.kernel.org>, <jgarzik@pobox.com>,
	"cramerj" <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	<davem@davemloft.net>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:6690 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031556AbXEDUnp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 16:43:45 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070504130110.0694aee6@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Just because they want to standardize, and put it in hardware 
> doesn't mean it is a good idea and Linux needs to support it!

I gave this as the motivation for the original idea.  But these patches
have been under scrutiny in the community for months now, and nobody
seemed to think they were totally wrong in design, just a few
implementation issues.  I did not design this specifically for this
technology either; this was the original idea, but the idea of allowing
the kernel to manage multiple queues on the NIC is the main focus here,
which many people seemed to like.  What happened that shifted that
perception?

> Why is it better for hardware to make the "next packet to 
> send" decision?
> For wired ethernet, I can't see how adding the complexity of 
> fixed number of small queues is a gain. Better to just do the 
> priority decision in software and then queue it to the 
> hardware. This seems like the old Token Ring and MAP/TOP 
> style crap crammed on top of Ethernet.

Are you saying it'd be better for the flow control requests per priority
to come up into the stack?  If you look closely at what I proposed in my
patches, it's just an API exposing the queues in the NIC to the kernel.
That's all.  How the hardware handles it is completely independent to
these patches.  If hardware exists that wants the granularity to
start/stop queues independent of each other and continue to have traffic
flow, I really think it should be able to do that.  That is all these
patches are providing.  Jamal and I talked about the original
motivation, and so I shared that with the community.  I don't want the
focus to shift to a proposed standard that could take advantage of these
patches; rather, I'd like the focus to remain on the patches themselves,
and what they're providing.  And if someone can explain to me why 2
months of review and scrutiny of these patches has shifted in another
direction, I'd really like to understand that.

Thanks,

-PJ Waskiewicz
