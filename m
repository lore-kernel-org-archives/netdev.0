From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [PATCH] can-raw: Fix skb_orphan_try handling
Date: Tue, 03 Aug 2010 18:14:41 +0200
Message-ID: <1280852081.3266.834.camel@pohly-mobl1.ikn.intel.com>
References: <4C529EFB.4090601@hartkopp.net>
	 <20100801.010337.68133932.davem@davemloft.net>
	 <4C555168.3090800@hartkopp.net>
	 <20100803.003056.216763358.davem@davemloft.net>
	 <4C583447.8010004@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"socketcan-core@lists.berlios.de" <socketcan-core@lists.berlios.de>,
	"matthias.fuchs@esd.eu" <matthias.fuchs@esd.eu>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:27834 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932351Ab0HCQOu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 12:14:50 -0400
In-Reply-To: <4C583447.8010004@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-08-03 at 18:22 +0300, Oliver Hartkopp wrote:
> >> The flags are tested all together in skb_orphan_try() ...
> > 
> > This is why I hate using unions in situations like this... it makes
> > code impossible to audit easily.
> > 
> > This damn thing should just be a "u8 flags" and a bunch of bit mask
> > CPP macro defines for the various boolean values.
> 
> Yep! I also felt like this.
> 
> Maybe Patrick Ohly can give some feedback, if he's ok with that kind of
> change. So far there are only a few places that would need to be changed for
> the flags bitops.

I'm fine with using a simple u8. I'm not sure where I picked up the
union thing, it's not something that I usually do in my own code.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.


