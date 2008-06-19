From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: Multiple TX queue implementation and Batching
Date: Thu, 19 Jun 2008 14:47:52 +0530
Message-ID: <OF38F6814F.441FEEF8-ON6525746D.0032B3BA-6525746D.00331325@in.ibm.com>
References: <20080619.021039.193704469.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([59.145.155.4]:55525 "EHLO
	e28esmtp04.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753615AbYFSJS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 05:18:56 -0400
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5J9ISS6028106
	for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 14:48:28 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5J9HWwJ749646
	for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 14:47:34 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5J9IPeD011236
	for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 14:48:25 +0530
In-Reply-To: <20080619.021039.193704469.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

David Miller <davem@davemloft.net> wrote on 06/19/2008 02:40:39 PM:

> Right now I'm just hacking drivers in preparation for this, so
> that the transmit queueing is seperated from the location
> in the driver where this actually occurs.
>
> I'll post a set of tg3 driver patches once I'm done debugging
> things.

What about core networking changes? I think you were planning to
remove a lot of stuff (device busy checks, requeue's, etc?) and
also implement lockless code (sch_generic.c at the very least).
Are those ready for taking an initial look?

Thanks,

- KK

