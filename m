From: David Miller <davem@davemloft.net>
Subject: Re: [RFT 2/4] Add mod_timer_noact
Date: Wed, 18 Feb 2009 01:30:07 -0800 (PST)
Message-ID: <20090218.013007.117003889.davem@davemloft.net>
References: <20090218051906.174295181@vyatta.com>
	<20090218052747.437271195@vyatta.com>
	<20090218092041.GC3294@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, kaber@trash.net, rick.jones2@hp.com,
	dada1@cosmosbay.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, tglx@linutronix.de,
	gandalf@wlug.westbo.se
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45420
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751582AbZBRJaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 04:30:23 -0500
In-Reply-To: <20090218092041.GC3294@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 18 Feb 2009 10:20:41 +0100

> Why dont you use something like this instead:
> 
> 	if (del_timer(timer))
> 		add_timer(timer);
> 
> ?

Why don't you read his commit message?

At least show him that much respect if you're going to
be against his patch.
