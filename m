From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: Splitting e1000 (Was: Re: e1000: backport ich9 support from 7.5.5
 ?)
Date: Fri, 13 Jul 2007 14:45:35 -0700
Message-ID: <4697F27F.6060107@intel.com>
References: <46857C08.4030303@intel.com>	<20070629150350.414553d4.akpm@linux-foundation.org>	<4685838D.9080108@garzik.org>	<c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>	<46859F3F.305@garzik.org>	<4685C09B.7040908@intel.com>	<20070630082520.GA20140@infradead.org>	<468AD23A.4090904@intel.com>	<468D8B32.9020305@garzik.org>	<468EDAF9.3020606@intel.com>	<20070707190431.GA26341@electric-eye.fr.zoreil.com>	<46900B83.1060902@intel.com> <20070707183244.19d21893@freepuppy.rosehill.hemminger.net> <469110F6.2030902@linux.intel.com> <4691279C.8030603@garzik.org> <46914382.8090801@linux.intel.com> <469280F5.8000909@garzik.org> <46929EBB.3000809@intel.com> <4692B611.1050603@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Christoph Hellwig <hch@infradead.org>,
	Andrew Grover <andy.grover@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"Ronciak, John" <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:62141 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757684AbXGMVph (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 17:45:37 -0400
In-Reply-To: <4692B611.1050603@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> I would strongly vote for taking a stripped down e1000new then, mask out 
>> all the pci id's except ich9, remove all code for pre-pci-e silicon and 
>> remove the most annoying and needlessly complexing code like the 
>> semi-implemented multiqueue code that is in there.
> 
> I'm fine for that as a path forward.  I would think that would zap a lot 
> of the hooks.
> 
>> How we are going to improve the internal api then can subsequently be 
>> done upstream in steps: implement using phylib, reorganize the code. 
>> This would give the community a view on the progress.
>>
>> I fear that if I spend yet another 2 months offline working on making a 
>> minimal ich9 driver I will lose even more time and patience: Even though 
>> the current driver (with pre-pci-e stripped) might not be as nice as you 
>> want, at least we can work together on it. I would rather go with 
>> something I know that works, isn't too bad, and we have time and start 
>> reviewing upstream immediately.
> 
> "minimal ich9 driver" is more a metaphor, describing the seed from which 
> a clean driver would logically grow:  imagine a minimal ich9 driver, 
> then add TSO, add support for other PCI-e phys, etc.  Whether you do 
> this exercise in your head or on the computer makes no difference, as 
> long as you can see what the end result should look like.
> 
> Not asking for yet another driver...  Start with e1000new or whatever 
> base you like.  Post driver for review, get feedback, update, lather, 
> rinse, repeat.  If we're all responsive, it should not take long at all 
> to get something upstream-mergeable.  Solve the "big potato" issues 
> especially :)
> 
> 
>> Agreed. All current e1000 pci-e hardware is based on the same mac, so 
>> it's the logical split. The differences are PHYs and manageability, but 
> 
> OK

Sorry for not replying to this earlier (I was on vacation for 2 days). We had 
some internal discussions and all the noses appear to be facing in the proper 
direction. I'm very happy with this and it will be my highest priority to make 
this work. I will attempt to get a quick start on this and come with a start 
point driver as soon as I can. Thanks to everyones who commented!

Auke
