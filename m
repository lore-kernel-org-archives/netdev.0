From: "Fu Cheng Peng, Franklin" <ASCPFu@ntu.edu.sg>
Subject: RE: [PATCH] TCP Veno module for kernel 2.6.16.13
Date: Fri, 26 May 2006 14:32:04 +0800
Message-ID: <7CD06E15ADF4104A9F2E4DC2DE678F89034325F3@EXCHANGE21.staff.main.ntu.edu.sg>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <shemminger@osdl.org>, <baruch@ev-en.org>, <jmorris@namei.org>,
	<netdev@vger.kernel.org>, "#ZHOU BIN#" <ZHOU0022@ntu.edu.sg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp2.ntu.edu.sg ([155.69.5.9]:18193 "EHLO exsmtp2.ntu.edu.sg")
	by vger.kernel.org with ESMTP id S1751293AbWEZGcC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 02:32:02 -0400
Content-class: urn:content-classes:message
To: <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Friday, May 26, 2006 4:24 AM
>To: #ZHOU BIN#
>Cc: shemminger@osdl.org; baruch@ev-en.org; jmorris@namei.org;
netdev@vger.kernel.org
>Subject: Re: [PATCH] TCP Veno module for kernel 2.6.16.13
>
>
>From: "#ZHOU BIN#" <ZHOU0022@ntu.edu.sg>
>Date: Thu, 25 May 2006 16:30:48 +0800
>
>> Yes, I agree. Actually the main contribution of TCP Veno is not in 
>> this AI phase. No matter the ABC is added or not, TCP Veno can always

>> improve the performance over wireless networks, according to our 
>> tests.
>
>It seems to me that the wireless issue is seperate from congestion
control.
>
>The key is to identify "true loss" due to overflow of intermediate
router queues, vs. "false loss" which is due to 
>temporary radio signal interference.

Quite agree

>
>This determination is a job for the loss detection in the generic ACK
processing code in tcp_input.c, not for a 
>congestion control algorithm.
>The congestion control algorithm uses the "true loss" information to
make congestion control decisions.

That is right, TCP Veno has two parts: one contribution is the smart
detection of congestion loss and random loss, another contribution part
is how to use this information perform congestion control intelligently.
The original veno paper in IEEE JSAC 2003 and many verified work can be
accessed on http://www.ntu.edu.sg/home/ascpfu/veno/veno.html
 


>We already have code that tries to make this differentiation, in the
form of FRTO, and your techniques can likely be 
>placed there as well.
