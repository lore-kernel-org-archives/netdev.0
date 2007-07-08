From: Jonathan Lundell <linux@lundell-bros.com>
Subject: Re: [E1000-devel] RFR: New e1000 driver (e1000new), was: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Sun, 8 Jul 2007 15:01:37 -0700
Message-ID: <5F1B56E5-479D-4E21-8640-B2F8C54850F7@lundell-bros.com>
References: <1183138159.17243.16.camel@blaa> <20070629175006.GB3917@falooley.org>	<468571C6.3090305@garzik.org> <46857C08.4030303@intel.com> <20070629150350.414553d4.akpm@linux-foundation.org> <4685838D.9080108@garzik.org> <468594B7.6070309@intel.com> <468597F7.2050700@linux.intel.com> <46912AEA.3030604@garzik.org> <4691458B.50403@linux.intel.com>
Mime-Version: 1.0 (Apple Message framework v752.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Mark McLoughlin <markmc@redhat.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"Ronciak, John" <john.ronciak@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gretel.pobox.com ([208.58.1.197]:56352 "EHLO gretel.pobox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757624AbXGHWQy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jul 2007 18:16:54 -0400
Received: from rune.pobox.com (rune.pobox.com [208.210.124.79])
	by gretel.pobox.com (Postfix) with ESMTP id 145F465EE7CA
	for <netdev@vger.kernel.org>; Sun,  8 Jul 2007 18:04:31 -0400 (EDT)
In-Reply-To: <4691458B.50403@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Jul 8, 2007, at 1:14 PM, Arjan van de Ven wrote:

>> I reject the notion that a "flag day" switchover for a huge mass of
>> e1000 users is the correct path.  I do not think that best serves  
>> Linux
>> users.
>
> so the options we have is do it one pci id a time; and the suggestion
> by others like Christoph has been to make the split at the PCI Express
> switchover. Do you agree with that approach?

My preference, as someone who has to support pretty much all  
generations of e1000-supported hardware in the field running critical  
applications is for a single well-structured driver. Qualifying a new  
release of the driver is a big deal, and having to qualify two of  
them doesn't really appeal to me.

We're seeing at least a couple of generations of mainboard that will  
have both PCIe and PCI-X slots (and adapters) in them, so even in the  
same box a PCIe split would require us to use both drivers. If  
splitting the driver really makes for substantial simplification of  
both, I suppose that's a compensating benefit, but it's not purely  
beneficial.

The e1000 driver (and the team behind it) has been a blessing to our  
business. Whatever they're doing right, I'd like to see them keep  
doing it.
