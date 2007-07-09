From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: Splitting e1000 (Was: Re: e1000: backport ich9 support from 7.5.5
 ?)
Date: Mon, 09 Jul 2007 12:36:52 -0700
Message-ID: <46928E54.9020607@linux.intel.com>
References: <46857C08.4030303@intel.com>	<20070629150350.414553d4.akpm@linux-foundation.org>	<4685838D.9080108@garzik.org>	<c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>	<46859F3F.305@garzik.org>	<4685C09B.7040908@intel.com>	<20070630082520.GA20140@infradead.org>	<468AD23A.4090904@intel.com>	<468D8B32.9020305@garzik.org>	<468EDAF9.3020606@intel.com>	<20070707190431.GA26341@electric-eye.fr.zoreil.com>	<46900B83.1060902@intel.com> <20070707183244.19d21893@freepuppy.rosehill.hemminger.net> <469110F6.2030902@linux.intel.com> <4691279C.8030603@garzik.org> <46914382.8090801@linux.intel.com> <469280F5.8000909@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
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
Received: from mga05.intel.com ([192.55.52.89]:29065 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755093AbXGITjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 15:39:03 -0400
In-Reply-To: <469280F5.8000909@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

<I'll leave the first two to Auke; the discussion I had with Auke on 
Friday was that he felt that a lot of the "ugly" stuff you complained 
about will go away if there is a PCI-E/older split, the PCI-E cards 
are more or less of the same "major generation", while pre-PCI-E is 
different>

> 3) Looming over everything else, is I wonder if Intel has recognized 
> that a maintainership problem exists: lack of ongoing cleanups and lack 
> of "focus" on issues not directly related to enabling new features?
> 
> My only "bias" against Intel is that I am -nervous- that past history 
> will continue, with regards to the "stuff it into the driver and move 
> on" driver maintenance regime.  Even most clean driver in the world will 
> fall upon hard times if under-maintained.

We (the Intel people on this mail and various others inside Intel) 
have been working hard to fix this issue several levels of management 
up in the networking group and I am confident we have all the buy-in 
to do the right thing now, and Auke has the time to do this. This was 
quite an effort at Intel-internal politics, and that's obviously 
something you don't (want to) care about or should have to care 
about.... but the end result is that finally in the last month or two 
things changed enough that I feel that the maintenance issue can be 
done right. The flipside sort of is that there needs to be a chance to 
prove this ;)

(and if you feel that it's not working please contact me so that I can 
re-escalate things; I'll also be monitoring how things go)

> Receiving feedback, disappearing for months, and then reappearing with 
> "blessed" changes is not adequate.  netdev@vger.kernel.org and 
> netdev-2.6.git need to be the primary vehicle for e1000[new] 
> development, maintained through small incremental changes streaming into 
> the kernel.  (though I do understand the constraints of hardware 
> go-public release dates)

Actually the biggest constraint for new hardware support is having 
working prototypes ;-)
The market is such that there may be only a short time between having 
a working prototype and a launch. (Before that there are design specs 
of course, but reality is that unless you can do basic unit testing 
shipping code for such new things is not a good thing, the chance of 
things "just working" is obviously pretty low).
