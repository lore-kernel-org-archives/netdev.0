From: James Chapman <jchapman@katalix.com>
Subject: Re: Splitting e1000 (Was: Re: e1000: backport ich9 support from 7.5.5
 ?)
Date: Sat, 07 Jul 2007 14:58:42 +0100
Message-ID: <468F9C12.8070600@katalix.com>
References: <1183138159.17243.16.camel@blaa> <20070629175006.GB3917@falooley.org> <468571C6.3090305@garzik.org> <46857C08.4030303@intel.com> <20070629150350.414553d4.akpm@linux-foundation.org> <4685838D.9080108@garzik.org> <c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com> <46859F3F.305@garzik.org> <4685C09B.7040908@intel.com> <20070630082520.GA20140@infradead.org> <468AD23A.4090904@intel.com> <468D8B32.9020305@garzik.org> <468EDAF9.3020606@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Christoph Hellwig <hch@infradead.org>,
	Andrew Grover <andy.grover@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>,
	Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"Ronciak, John" <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	'Stephen Hemminger' <shemminger@linux-foundation.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Arjan van de Ven <arjan@linux.intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:53777 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753699AbXGGN7E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Jul 2007 09:59:04 -0400
In-Reply-To: <468EDAF9.3020606@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> I don't think that anyone besides you and maybe one or two others are 
> interested in doing this rewrite from scratch. 

I count myself as one of those others. :) I don't think it's a rewrite 
though; it's a rework.

> The rest of us would 
> rather see something much more similar to my original suggestion which 
> relieves the ich9-wishes for everyone and provides a good starting point 
> to go forward. Not to mention that a lot of that code is already there, 
> and at least cleaned up quite a bit already.

But the structure of it isn't right, as mentioned by Jeff and I in 
previous posts. Any restructuring of your new driver will obviously take 
time. In my view using the urgency of needing ich9 support to get the 
new driver in isn't the right tradeoff. Perhaps the ich9 code should be 
backported into the existing e1000, which is where this thread started? 
This will buy time to restructure the new driver to make sure it is 
right for the future.

I agree with Jeff that the initial version of the new driver should have 
only essential features - bells and whistles can be added incrementally.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

