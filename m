From: Andi Kleen <andi@firstfloor.org>
Subject: Re: CPU utilization increased in 2.6.27rc
Date: Wed, 13 Aug 2008 22:03:35 +0200
Message-ID: <87tzdoznqg.fsf@basil.nowhere.org>
References: <48A23137.2010107@myri.com>
	<20080812.181549.229367205.davem@davemloft.net>
	<48A30834.4090802@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	robert@robur.slu.se
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:35903 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbYHMUDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 16:03:38 -0400
In-Reply-To: <48A30834.4090802@myri.com> (Andrew Gallatin's message of "Wed, 13 Aug 2008 12:13:40 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Gallatin <gallatin@myri.com> writes:
>
> 8363      6.5081  vmlinux                  _raw_spin_lock
> 5612      4.3672  oprofiled                (no symbols)
> 4420      3.4396  ehci_hcd                 (no symbols)
> 4325      3.3657  vmlinux                  handle_IRQ_event
> 3688      2.8700  vmlinux                  default_idle
> 3164      2.4622  vmlinux                  nv_start_xmit_optimized
> 3092      2.4062  vmlinux                  sk_run_filter
                                             ^^^^^^^^^^^^^

Looks like you have one of those nasty dhcpcds running that
always open a raw socket and intercept everything using a filter?
I always hoped those would disappear eventually and just
bind to the proper protocol, but they seem to refuse dying.

-Andi
