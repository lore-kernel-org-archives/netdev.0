From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 16:21:20 -0400
Message-ID: <1178828480.4062.98.camel@localhost>
References: <OF305F038C.A48D4C37-ON652572D7.00538ECA-652572D7.00546E39@in.ibm.com>
	 <46435412.50800@hp.com>
	 <1178820423.17393.3.camel@w-sridhar2.beaverton.ibm.com>
	 <464375F9.1050600@gmail.com> <1178827887.4062.90.camel@localhost>
	 <46437D53.7000209@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Rick Jones <rick.jones2@hp.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
To: Gagan Arneja <gaagaan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.224]:26077 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755115AbXEJUVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 16:21:24 -0400
Received: by wx-out-0506.google.com with SMTP id h31so663527wxd
        for <netdev@vger.kernel.org>; Thu, 10 May 2007 13:21:23 -0700 (PDT)
In-Reply-To: <46437D53.7000209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-10-05 at 13:15 -0700, Gagan Arneja wrote:

> Really! It's just the transmit routine. How radical can that be?
> 

Ok, you have a point there, but it could be challenging with many
tunables:
For example:
my biggest challenge with the e1000 was just hacking up the DMA setup
path - i seem to get better numbers if i dont kick the DMA until i stash
all the packets on the ring first etc. It seemed counter-intuitive.

Now if you can ammortize PCI operations as well (the 10K cycles you
pointed out), i think thats where you get the best bang for the buck.

cheers,
jamal


