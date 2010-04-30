From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH linux-next v3 1/2] irq: Add CPU mask affinity hint
Date: Fri, 30 Apr 2010 22:24:01 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1004302220270.2951@localhost.localdomain>
References: <20100430202343.4591.66240.stgit@ppwaskie-hc2.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, arjan@linux.jf.intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:43844 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758302Ab0D3UYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 16:24:15 -0400
In-Reply-To: <20100430202343.4591.66240.stgit@ppwaskie-hc2.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter,

On Fri, 30 Apr 2010, Peter P Waskiewicz Jr wrote:
>  
> +extern int irq_register_affinity_hint(unsigned int irq,
> +                                      const struct cpumask *m);

One last nitpick. 

Can you please rename to irq_set_affinity_hint() ?

Otherwise, I'm happy with the outcome. Thanks for your patience!

Thanks,

	tglx
