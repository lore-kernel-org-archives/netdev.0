From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [E1000-devel] e1000: backport ich9 support from 7.5.5 ?
Date: Fri, 29 Jun 2007 19:34:19 -0700
Message-ID: <4685C12B.1050705@intel.com>
References: <1183138159.17243.16.camel@blaa>	 <20070629175006.GB3917@falooley.org> <468571C6.3090305@garzik.org>	 <46857C08.4030303@intel.com>	 <20070629150350.414553d4.akpm@linux-foundation.org>	 <4685838D.9080108@garzik.org>	 <c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>	 <46859F3F.305@garzik.org> <ae023b600706291829r49fc8a6auf8a0df2ee2d5cb15@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Grover <andy.grover@gmail.com>,
	Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>
To: Jim McCullough <jim.mccullough@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12212 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752373AbXF3Cef (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 22:34:35 -0400
In-Reply-To: <ae023b600706291829r49fc8a6auf8a0df2ee2d5cb15@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jim McCullough wrote:
> It goes back to ICH7 for the PCIe support.  That also includes models used
> as plugin PCIe devices.  I dont remember if ICH6 erra devices were PCI or
> PCIe.  I'll leave that part for Auke.
> 
> On 6/29/07, Jeff Garzik <jeff@garzik.org> wrote:
>> Andrew Grover wrote:
>>> I think making e1000new ICH9-and-newer isn't really the best place to
>>> split it. The Windows e1000 driver got split on the PCI->PCIe
>>> transition, something that clearly delineated what nics one driver
>>> supported, and the other. There's no real technical reason for
>>> splitting now other than "this was when e1000old collapsed under its
>>> own weight".
>>>
>>> The PCIe adapters are also the first ones to support multiple queues
>>> IIRC, maybe that would be an another actual technical reason to split
>>> it there?
>> Can knowledgeable people characterize the PCIe adapters somehow?  Is
>> that "ICH8-era and later", or does it go back further than that?

ich7 and 6 are sold with various on-board NICs, often pre-pcie e1000 silicon 
like 82547 and 82546. Some newer models (lenovo, toshiba) laptops pack 82573, 
but basically ich chipsets before ich8 did not have an in-chipset MAC, so they 
are irrelevant for this story.

only es2lan, ich8 and ich9 have true on-board MAC's.

Auke
