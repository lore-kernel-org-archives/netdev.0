From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [rfc] new sk_buff member: hwstamp
Date: Mon, 14 Jul 2008 23:07:11 +0300
Message-ID: <200807142307.11575.opurdila@ixiacom.com>
References: <200807141843.00845.opurdila@ixiacom.com> <200807142130.12375.opurdila@ixiacom.com> <487BA1B8.5070006@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4062 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756077AbYGNUJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 16:09:22 -0400
In-Reply-To: <487BA1B8.5070006@hartkopp.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 14 July 2008, Oliver Hartkopp wrote:
>
> > The problem for this approach in our usecase (one way delay measurement)
> > is that the real time clock of the CPUs (of the RX and TX ports) is not
> > synchronized, but the hw timestamp (implemented in the NIC/FPGA) is.
>
> Is it necessary to have syncronized clocks on the different CPUs or is
> it feasible to calculate a per-cpu-clock offset in your driver, so that
> you can build a complete timing overview of your setup?
>

Sorry,  what I meant by CPU is a complete and independent system: CPU + memory 
+ NIC. The real time of the CPUs of the two systems are not synchronized, but 
the NIC clock of both systems is.

Thanks,
tavi
