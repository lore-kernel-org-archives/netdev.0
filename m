From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 10/11][TG3]: Reduce spurious interrupts.
Date: Mon, 07 May 2007 10:44:14 -0700
Message-ID: <463F656E.5060802@hp.com>
References: <1551EAE59135BE47B544934E30FC4FC0940105@nt-irva-0751.brcm.ad.broadcom.com>	<463F5655.7050107@hp.com> <1178562469.4859.70.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:36100 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754586AbXEGRoS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 13:44:18 -0400
In-Reply-To: <1178562469.4859.70.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> On Mon, 2007-05-07 at 09:39 -0700, Rick Jones wrote:
> 
>>On how "topologically big" a system has this resurrection of the PIO read been 
>>tried so far?
>>
> 
> 
> If you're asking how much impact the read will have on performance, the
> answer is that it will depend on whether you frequently get spurious
> interrupts or not without the read.  The read itself has a measurable
> impact on performance, but it will offset the performance hit of
> entering the IRQ handler twice if you get frequent spurious interrupts.
> It also prevents the kernel from shutting down the IRQ in some extreme
> cases.
> 
> If you get spurious interrupts infrequently, the read is unfortunately a
> net loss.

Mostly I was thinking that not all PIO reads are the same "length" and so the 
effect of the PIO read will vary, perhaps considerably, with the platform, 
particularly for a very large NUMA platform.

rick jones
