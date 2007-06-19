From: jamal <hadi@cyberus.ca>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Tue, 19 Jun 2007 12:24:45 -0400
Message-ID: <1182270285.4968.68.camel@localhost>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com>
	 <1181216629.4064.22.camel@localhost>  <20070619132148.GA32078@2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:4516 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753028AbXFSQYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 12:24:51 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1880359wxc
        for <netdev@vger.kernel.org>; Tue, 19 Jun 2007 09:24:51 -0700 (PDT)
In-Reply-To: <20070619132148.GA32078@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-19-06 at 17:21 +0400, Evgeniy Polyakov wrote:

> I've ran several simple tests with desktop e1000 adapter I managed to
> find.

Mucho gracias Evgeniy. 

> Test machine is amd athlon64 3500+ with 1gb of ram.
> Another point is dektop core duo 3.4 ghz with 2 gb of ram and sky2
> driver.
> 
> Simple test included test -> desktop and vice versa traffic with 128 and
> 4096 block size in netperf-2.4.3 setup.
> 

Sounds good enough for starters. 

> Test machine runs 2.6.22-rc5-batch and mainline tree (there is a test
> with 2.6.22-rc4 and there is a noticeble performance win compared to
> that tree in the latest git, likely tcp congestion changes resulted in
> better utilisation). 

Do you have tso on/off? I suspect youd see better numbers with tso off.

> Batched xmit has better numbers.

Much appreciated. It would be useful to sort of measure CPU utilization
as well (my understanding is netperf4 is more capable of that).
I think the benefit would be a lot more visible as the number of flows
goes up (simply because there will be a lot more packets/sec going into
the driver).

cheers,
jamal


