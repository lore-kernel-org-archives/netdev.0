From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Bonding and Neighbour Discovery on IPv6-only devices
Date: Mon, 15 Sep 2008 11:16:08 -0700
Message-ID: <2540.1221502568@death.nxdomain.ibm.com>
References: <200809151335.16817.asid@hp.com> <20080915180015.GB1078@havoc.gtf.org>
Cc: Alex Sidorenko <asid@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:56634 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519AbYIOSQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 14:16:22 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8FIGLPt009105
	for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 14:16:21 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8FIGKbL079162
	for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 12:16:20 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8G0GJM1032396
	for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 18:16:20 -0600
In-reply-to: <20080915180015.GB1078@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik <jeff@garzik.org> wrote:

>On Mon, Sep 15, 2008 at 01:35:16PM -0400, Alex Sidorenko wrote:
[...]
>> Everything works fine, but if we switch the slave doing
>> 
>> # ifenslave -c bond0 eth3
>> 
>> the incoming ping6 to this host stops for up to several minutes (waiting until 
>> the switch updates its caches).
>
>We _just_ put in an IPv6 fix, FWIW...

	The fix that just went in has to do with traffic balancing in
alb/tlb modes; this problem has to do with the lack of an IPv6
equivalent to a gratuitous ARP during a user-induced failover.

	I'm looking into this; it might be simple to fix.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
