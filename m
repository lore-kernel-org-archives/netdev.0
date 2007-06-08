From: jamal <hadi@cyberus.ca>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Fri, 08 Jun 2007 07:43:28 -0400
Message-ID: <1181303008.4063.47.camel@localhost>
References: <OF7E8226CB.9B6FDC92-ON652572F4.003E9F60-652572F4.003F4BE0@in.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Gagan Arneja <gaagaan@gmail.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.224]:2263 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965713AbXFHLnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 07:43:32 -0400
Received: by wx-out-0506.google.com with SMTP id t15so704573wxc
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2007 04:43:31 -0700 (PDT)
In-Reply-To: <OF7E8226CB.9B6FDC92-ON652572F4.003E9F60-652572F4.003F4BE0@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

KK,

On Fri, 2007-08-06 at 17:01 +0530, Krishna Kumar2 wrote:


> I thought it comes to 1.147Mpps, or did I calculate wrong
> (70*1024*1024/8/8) ?

I assumed 8B to mean data that is on top of TCP/UDP?
If so then in the case of UDP we have 8B UDP header, 20B IP and 14B
ethernet < 64B minimal allowed Ethernet packet; so it gets padded and
goes out as 64B.
There are, as you state above, 1.147(or is it 1.48?) such packets/sec in
1Gbps.
So (70Mbps/1000Mbps)*1.147 is the rough number i was reffering to.


> My script was doing that earlier, I trimmed all that to make it easier
> to understand. Will post the larger version later.

That will be nice because remember we can have multiple CPU packet
producers but only one CPU consumer.

> > no problem.
> 
> Thanks, please let me know what you think of the patch I sent earlier.

I havent seen a patch. Can you resend it?

> I am running a larger 5 iteration run with buffer sizes :8,32,128,512,1
> K,4K,16K.
> It is going to run for around 12 hours and since I am moving house during
> the
> weekend, I will be able to look at the results only on Monday.
> 

sounds good.

cheers,
jamal

