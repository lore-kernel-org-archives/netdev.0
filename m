From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC V2 PATCH] rtnetlink: Add method to calculate dump info
 data size
Date: Mon, 9 May 2011 21:25:36 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755018E1CF4BF@orsmsx508.amr.corp.intel.com>
References: <1304995413.3050.19.camel@edumazet-laptop>
	<20110509201705.409f6d39@nehalam>	<1304999127.3050.40.camel@edumazet-laptop>
 <20110509.204959.71127408.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:40169 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750793Ab1EJEZm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 00:25:42 -0400
In-Reply-To: <20110509.204959.71127408.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, May 09, 2011 8:50 PM
> To: eric.dumazet@gmail.com
> Cc: shemminger@vyatta.com; Rose, Gregory V; netdev@vger.kernel.org;
> bhutchings@solarflare.com
> Subject: Re: [RFC V2 PATCH] rtnetlink: Add method to calculate dump info
> data size
> 
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 10 May 2011 05:45:27 +0200
> 
> > We only need to maintain a global variable to hold min_dump_alloc
> >
> > [ and only increase this variable when necessary, not bother to decrease
> > it when removing a driver ]
> 
> Agreed, this is probably the best approach.
[Greg Rose] 

OK, let me go back and look at doing it this way.  I was sort of scratching my head about doing that device lookup on every dump, so this is a good suggestion.

Thanks,

- Greg

