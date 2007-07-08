From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: Splitting e1000 (Was: Re: e1000: backport ich9 support from 7.5.5
 ?)
Date: Sun, 08 Jul 2007 13:05:22 -0700
Message-ID: <46914382.8090801@linux.intel.com>
References: <46857C08.4030303@intel.com>	<20070629150350.414553d4.akpm@linux-foundation.org>	<4685838D.9080108@garzik.org>	<c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>	<46859F3F.305@garzik.org>	<4685C09B.7040908@intel.com>	<20070630082520.GA20140@infradead.org>	<468AD23A.4090904@intel.com>	<468D8B32.9020305@garzik.org>	<468EDAF9.3020606@intel.com>	<20070707190431.GA26341@electric-eye.fr.zoreil.com>	<46900B83.1060902@intel.com> <20070707183244.19d21893@freepuppy.rosehill.hemminger.net> <469110F6.2030902@linux.intel.com> <4691279C.8030603@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Christoph Hellwig <hch@infradead.org>,
	Andrew Grover <andy.grover@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>,
	Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"Ronciak, John" <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:35934 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755455AbXGHUHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2007 16:07:17 -0400
In-Reply-To: <4691279C.8030603@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Arjan van de Ven wrote:
>> I'd second this; also lets be honest and fair about things and use a 
>> similar standard for all drivers; are we going to ask all driver 
>> submitters to remove NAPI, TSO and other stuff? I would hope not. Are 
> 
> That was merely a suggestion.  My general meaning was "small driver is 
> easier to get into the kernel and into the field."

it didn't quite come across as a suggestion, but if it was only a 
suggestion then ok; it's not really a practical option.

>> all new drivers that have even a single bitfield going to be rejected? 
>> That's be a new rule but ok, if it applies to all drivers it's fair.
> 
> That's one of a gazillion checklist items that a new driver has to pass 
> through.  You know how it works for new drivers.
> 
> "it looks better than our last try" and "it looks better than that ugly 
> driver over there" does not grant you a free pass on review.

I know how it works for new drivers; they need to be good enough to 
maintain forward and form a burden on the stack/maintainers. Any 
remaining items need to be small enough to not be a 'risk' for users.


>> What is there now is a driver that works, is relatively clean (and yes 
>> if you look deep enough you can ALWAYS nitpick on any code, even 
>> Linus' or Jeff's best code) and provides good performance with all the 
>> features a modern ethernet driver is supposed to have.
> 
> Is this is the attitude, what's the point of even posting the driver for 
> review?  Intel posted e1000new on June 29.  Feedback was then posted. 

and feedback is being incorperated.

> Ten days later, without a single revision, Intel declares its own driver 
> clean and working and good enough for merging as-is.

No. Arjan looked at driver and sees a rather clean driver compared to 
some of the other recently merged drivers, sees a list of relatively 
simple todos (some of which obviously aren't merge stoppers, others 
are) and hopes that this driver will be treated objectively without 
the appearance of having different levels of bars depending on what 
your email address ends with.
