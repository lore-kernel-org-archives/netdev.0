From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] bnx2x: Insane RX rings
Date: Fri, 10 Sep 2010 08:46:06 -0700
Message-ID: <4C8A52BE.9040105@hp.com>
References: <1284065105.4782.11.camel@edumazet-laptop>	<4C894FBD.2020109@ans.pl>	<20100909.143001.104050644.davem@davemloft.net>	<4C8953D3.9060204@hp.com> <1284117374.30831.2.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, "ole@ans.pl" <ole@ans.pl>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:29255 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941Ab0IJPqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 11:46:09 -0400
In-Reply-To: <1284117374.30831.2.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>I think simply that the RX queue size should be scaled by the number
>>>of queues we have.
> 
> 
> There are few factors that can be considered when scaling the ring
> sizes:
> - Number of queues per device
> - Number of devices
> - Available amount of memory
> - Others...
 >
> I'm thinking about adding a factor only according to the number of
> queues - this will still cause issues for systems with many ports. Does
> that sound reasonable or not enough? Do you think the number of devices
> or even the amount of free memory should be considered?

At one level we are talking about horses and barn doors - for example, the 
minimum memory requirements for ProLiants have already been set (and 
communicated for some time) taking memory usage of their LOMs (Lan On 
Motherboard) into account.

rick jones
