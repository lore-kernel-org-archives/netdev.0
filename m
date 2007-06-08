From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Fri, 8 Jun 2007 17:01:21 +0530
Message-ID: <OF7E8226CB.9B6FDC92-ON652572F4.003E9F60-652572F4.003F4BE0@in.ibm.com>
References: <1181301246.4063.15.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Gagan Arneja <gaagaan@gmail.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Sridhar Samudrala <sri@us.ibm.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp06.au.ibm.com ([202.81.18.155]:57481 "EHLO
	ausmtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968459AbXFHLcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 07:32:22 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp06.au.ibm.com (8.13.8/8.13.8) with ESMTP id l58BXX851355830
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 21:33:33 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l58BZjwh175340
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 21:35:46 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l58BVp4h004283
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 21:31:55 +1000
In-Reply-To: <1181301246.4063.15.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jamal,

J Hadi Salim <j.hadi123@gmail.com> wrote on 06/08/2007 04:44:06 PM:

> That should be fine as long as the sender is running the patched
> 2.6.22-rc4

Definitely :)

> Thats interesting - it is possible there is transient burstiness which
> fills up the ring.
> My observation of your results (hence my comments): for example the
> buffer size = 8B, TCP 1 process you achieve less than 70M.  That is less
> than 100Kpps on average being sent out. Very very tiny - so it is
> interesting that it is causing a shutdown.

I thought it comes to 1.147Mpps, or did I calculate wrong
(70*1024*1024/8/8) ?

> Also note something else strange that it is kind of strange that
> something like UDP which doesnt backoff will send out less
> packets/second ;->

Cannot explain that either :)

> BTW, another interesting things to do is ensure that several netperfs
> are running on different CPUs.

My script was doing that earlier, I trimmed all that to make it easier
to understand. Will post the larger version later.

> no problem.

Thanks, please let me know what you think of the patch I sent earlier.

I am running a larger 5 iteration run with buffer sizes :8,32,128,512,1
K,4K,16K.
It is going to run for around 12 hours and since I am moving house during
the
weekend, I will be able to look at the results only on Monday.

Regards,

- KK

