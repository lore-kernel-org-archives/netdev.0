From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: CPU utilization increased in 2.6.27rc
Date: Wed, 13 Aug 2008 16:36:27 -0400
Message-ID: <48A345CB.3090806@myri.com>
References: <48A23137.2010107@myri.com>	<20080812.181549.229367205.davem@davemloft.net>	<48A30834.4090802@myri.com> <87tzdoznqg.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	robert@robur.slu.se
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1984 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753201AbYHMUoG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 16:44:06 -0400
In-Reply-To: <87tzdoznqg.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> Andrew Gallatin <gallatin@myri.com> writes:
>> 8363      6.5081  vmlinux                  _raw_spin_lock
>> 5612      4.3672  oprofiled                (no symbols)
>> 4420      3.4396  ehci_hcd                 (no symbols)
>> 4325      3.3657  vmlinux                  handle_IRQ_event
>> 3688      2.8700  vmlinux                  default_idle
>> 3164      2.4622  vmlinux                  nv_start_xmit_optimized
>> 3092      2.4062  vmlinux                  sk_run_filter
>                                              ^^^^^^^^^^^^^
> 
> Looks like you have one of those nasty dhcpcds running that
> always open a raw socket and intercept everything using a filter?
> I always hoped those would disappear eventually and just
> bind to the proper protocol, but they seem to refuse dying.

Yeah, the box is running an ancient CENTOS4, so the dhcpcd
is pretty old.

Drew
