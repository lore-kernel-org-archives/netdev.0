From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Wed, 25 Apr 2007 10:45:50 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902B96813@orsmsx414.amr.corp.intel.com>
References: <1177501003.4082.20.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jgarzik@pobox.com>, "cramerj" <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	<davem@davemloft.net>
To: <hadi@cyberus.ca>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62231 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423341AbXDYRpx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 13:45:53 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1177501003.4082.20.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: J Hadi Salim [mailto:j.hadi123@gmail.com] On Behalf Of jamal
> Sent: Wednesday, April 25, 2007 4:37 AM
> To: Stephen Hemminger
> Cc: Waskiewicz Jr, Peter P; netdev@vger.kernel.org; 
> linux-kernel@vger.kernel.org; jgarzik@pobox.com; cramerj; 
> Kok, Auke-jan H; Leech, Christopher; davem@davemloft.net
> Subject: Re: [PATCH] IPROUTE: Modify tc for new PRIO 
> multiqueue behavior
> 
> On Tue, 2007-24-04 at 21:05 -0700, Stephen Hemminger wrote:
> > Peter P Waskiewicz Jr wrote:
> 
> > Only if this binary compatiable with older kernels.
> 
> It is not. But i think that is a lesser problem, the bigger 
> question is:
> Why would you need to change a qdisc just so you can support 
> egress multiqueues?

The previous version of my multiqueue patches I sent for consideration
had feedback from Patrick McHardy asking that the user be able to
configure the PRIO qdisc to run with multiqueue support or not.  That is
why TC needed a modification, since I agreed with Patrick that this
would be a useful option.

All the versions of multiqueue network device support I've sent for
consideration had PRIO modified to support multiqueue devices, since it
lends itself well for the model of multiple, independent flows.

> 
> BTW, is there any reason this is being cced to lkml?

Since this change affects how tc interacts with the qdisc layer, I cced
lkml.

> 
> cheers,
> jamal
> 
> PS:- I havent read the kernel patches (i am congested and 
> about 1000 messages behind on netdev) and my opinions may be 
> influenced by an approach i have in trying to help someone 
> fixup a wireless driver with multiqueue support.

As long as someone is looking at them, I'll be happy.  :-)

Thanks,

-PJ Waskiewicz
