From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH net-next-2.6 1/5] genirq: Add IRQ affinity notifiers
Date: Wed, 19 Jan 2011 22:53:02 +0100 (CET)
Message-ID: <alpine.LFD.2.00.1101192248350.3211@localhost6.localdomain6>
References: <alpine.LFD.2.00.1101192214350.3211@localhost6.localdomain6> <20110119.132730.57462002.davem@davemloft.net> <alpine.LFD.2.00.1101192229500.3211@localhost6.localdomain6> <20110119.134812.123988295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:40960 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754562Ab1ASVxO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jan 2011 16:53:14 -0500
In-Reply-To: <20110119.134812.123988295.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Jan 2011, David Miller wrote:
> From: Thomas Gleixner <tglx@linutronix.de>
> Date: Wed, 19 Jan 2011 22:39:04 +0100 (CET)
> > Nothing will happen and no hassels at all, because your tree and my
> > tree have the exact same commit with the exact same sha1. You don't
> > have further changes in your tree which touch genirq stuff and I don't
> > have anything which touches net.
> 
> You said you had stuff before Ben's patches, and that's why you needed
> to provide me with an -rc1 relative version of his commits.

Sorry, I meant other stuff pending (not yet applied) which will
interfere with that patch. And even if I would have pending patches in
git already it would not matter:

    tip/irq/core     some stuff based on whatever
    tip/irq/for-net  single patch based on rc1

tip/irq/core merges tip/irq/for-net _before_ offering it to Linus

You pull tip/irq/for-net and nothing breaks :)
 
> If that's not the case, then yes it would work just fine.
> 
> Just give me the URL to pull from, thanks!

Will do, give me a day or two !

Thanks,

	tglx
