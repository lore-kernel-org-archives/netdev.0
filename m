From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 12:08:11 -0400
Message-ID: <1178813291.4062.32.camel@localhost>
References: <20070510150833.GB24898@2ka.mipt.ru>
	 <OF305F038C.A48D4C37-ON652572D7.00538ECA-652572D7.00546E39@in.ibm.com>
	 <20070510154804.GA17474@2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:50894 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754866AbXEJQIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 12:08:15 -0400
Received: by wx-out-0506.google.com with SMTP id h31so588950wxd
        for <netdev@vger.kernel.org>; Thu, 10 May 2007 09:08:14 -0700 (PDT)
In-Reply-To: <20070510154804.GA17474@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-10-05 at 19:48 +0400, Evgeniy Polyakov wrote:

> IMHO if you do not see in profile anything related to driver's xmit
> function, it does not require to be fixed. 

True, but i think there may be value in amortizing the cost towards
the driver. 
i.e If you grab a lock and send X packets vs a single packet, depending
on the cost of the lock you may observe a reduction in CPU.

I have tried similar experiments in the past and observed zero
improvements in sane machines, but huge improvements on insane machines.
Slides on my work here (just jump to about slide 93):
http://vger.kernel.org/jamal_netconf2006.sxi

One thought i had at the time was perhaps the e1000 DMA setup/teardown
was very inefficient.

As the slides indicate i was trying to get throughput improvements but
failed to seen any on sane machines.
A suggestion made to me was to look at CPU utilization as a metric.
Unfortunately i havent had any chance yet.

cheers,
jamal

