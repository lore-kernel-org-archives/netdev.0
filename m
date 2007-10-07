From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 2/5] forcedeth: interrupt handling cleanup
Date: Sun, 7 Oct 2007 11:03:13 +0200
Message-ID: <20071007090313.GA733@elte.hu>
References: <20071006151250.GA17020@havoc.gtf.org> <20071006151400.GB17488@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:51522 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752130AbXJGJDZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2007 05:03:25 -0400
Content-Disposition: inline
In-Reply-To: <20071006151400.GB17488@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Jeff Garzik <jeff@garzik.org> wrote:

> -			spin_unlock(&np->lock);
> -			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq.\n", dev->name, i);
> -			break;

i like that! One forcedeth annoyance that triggers frequently on one of 
my testboxes is:

[  120.955202] eth0: too many iterations (6) in nv_nic_irq.
[  121.233865] eth0: too many iterations (6) in nv_nic_irq.
[  129.215450] eth0: too many iterations (6) in nv_nic_irq.
[  139.734408] eth0: too many iterations (6) in nv_nic_irq.
[  144.546811] eth0: too many iterations (6) in nv_nic_irq.
[  153.811005] eth0: too many iterations (6) in nv_nic_irq.
[  154.695879] eth0: too many iterations (6) in nv_nic_irq.
[  155.455078] eth0: too many iterations (6) in nv_nic_irq.
[  173.912162] eth0: too many iterations (6) in nv_nic_irq.

	Ingo
