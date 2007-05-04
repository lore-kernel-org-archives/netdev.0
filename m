From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Fri, 4 May 2007 13:01:10 -0700
Message-ID: <20070504130110.0694aee6@freekitty>
References: <1178109829.4074.48.camel@localhost>
	<D5C1322C3E673F459512FB59E0DDC32902C70A5C@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <hadi@cyberus.ca>, "Patrick McHardy" <kaber@trash.net>,
	<netdev@vger.kernel.org>, <jgarzik@pobox.com>,
	"cramerj" <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	<davem@davemloft.net>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:45912 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422808AbXEDUGk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 16:06:40 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902C70A5C@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 3 May 2007 14:03:07 -0700
"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com> wrote:

> > Lets come up with some terminology; lets call multiqueue what 
> > the qdiscs do; lets call what the NICs do multi-ring.
> > Note, i have thus far said you need to have both and they 
> > must be in sync.
> 
> I agree with the terminology.
> 
> > This maybe _the_ main difference we have in opinion.
> > Like i said earlier, I used to hold the same thoughts you do.
> > And i think you should challenge my assertion that it doesnt 
> > matter if you have a single entry point; [my assumptions are 
> > back in what i called #b and #c].
> 
> Here is a paper that describes what exactly we're trying to do:
> http://www.ieee802.org/3/ar/public/0503/wadekar_1_0503.pdf.  Basically
> we need the ability to pause a queue independantly of another queue.
> Because of this requirement, the kernel needs visibility into the driver
> and to have knowledge of and provide control of each queue.  Please note
> that the API I'm proposing is a generic representation of the Datacenter
> Ethernet mentioned in the paper; I figured if we're putting in an
> interface to support it, it should be generic so other technologies out
> there could easily use it.
> 

Just because they want to standardize, and put it in hardware doesn't
mean it is a good idea and Linux needs to support it!

Why is it better for hardware to make the "next packet to send" decision?
For wired ethernet, I can't see how adding the complexity of fixed number
of small queues is a gain. Better to just do the priority decision in software
and then queue it to the hardware. This seems like the old Token Ring
and MAP/TOP style crap crammed on top of Ethernet.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
