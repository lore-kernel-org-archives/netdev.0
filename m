From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: gianfar select_queue bogosity
Date: Thu, 24 Dec 2009 12:06:09 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81BA0904F@zin33exm22.fsl.freescale.net>
References: <OF748A4720.94B5A869-ON65257695.00267BA3-65257695.0027EDC4@in.ibm.com><20091223.211157.68124463.davem@davemloft.net><9F4C7D19E8361D4C94921B95BE08B81BA0904E@zin33exm22.fsl.freescale.net> <20091223.222938.241429611.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <krkumar2@in.ibm.com>, <yinghai@kernel.org>,
	<e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>,
	<netdev-owner@vger.kernel.org>, <avorontsov@ru.mvista.com>,
	<galak@kernel.crashing.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:58493 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753164AbZLXGgM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 01:36:12 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20091223.222938.241429611.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net] 
>Sent: Thursday, December 24, 2009 12:00 PM
>To: Kumar Gopalpet-B05799
>Cc: krkumar2@in.ibm.com; yinghai@kernel.org; 
>e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org; 
>netdev-owner@vger.kernel.org; avorontsov@ru.mvista.com; 
>galak@kernel.crashing.org
>Subject: Re: gianfar select_queue bogosity
>
>From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
>Date: Thu, 24 Dec 2009 11:34:23 +0530
>
>> What if I want to maintaing a 1-1 mapping b/w the Rx/Tx queues.
>> For eg., I want a packet received on queue-1 on eth0 to be forwarded 
>> on to queue-1 on eth1.
>
>That's what the default code does when forwarding/bridging!
>
>And for locally generated packets it uses the flow hash.
>
>What do you think we do by default?  Go read the code :-)
>

OOPS ..I am really sorry. I should have given a little thought before
providing the gfar_select_queue( ) function. Thanks for the pointer.

But then, on the Rx-side, we should also set the "queue_mapping" as
"queue_mapping +1", since skb_get_rx_queue( ) returns "queue_mapping
-1". Is this correct ?


--

Thanks
Sandeep
