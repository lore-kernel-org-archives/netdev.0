From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH] [sis900] convert to NAPI, WAS Re: pktgen terminating
 condition
Date: Wed, 05 Sep 2007 13:03:21 +0100
Message-ID: <46DE9B09.7060603@katalix.com>
References: <20070904032036.GA11153@ludhiana> <1188925008-ced672f60b90353067426d0b9f74506a@brownhat.org> <20070905074411.GA4815@ludhiana>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniele Venzano <venza@brownhat.org>, hadi@cyberus.ca,
	davem@davemloft.net, rick.jones2@hp.com, msb@google.com,
	netdev@vger.kernel.org, grundler@google.com,
	robert.olsson@its.uu.se, jeff@garzik.org, nhorman@tuxdriver.com
To: Mandeep Singh Baines <mandeep.baines@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:60868 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753360AbXIEMDi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2007 08:03:38 -0400
In-Reply-To: <20070905074411.GA4815@ludhiana>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mandeep Singh Baines wrote:
> Daniele Venzano (venza@brownhat.org) wrote:
>> The patch looks good and I think it can be pushed higher (-mm ?) for some wider 
>> testing. I don't have the hardware available to do some tests myself, 
>> unfortunately, but it would be similar to yours anyway.
>>
>> I'd like to know how this works for people with less memory and slower CPU, but any 
>> kind of test run will be appreciated.
> 
> Hi Daniele,
> 
> I tested the driver under different setting of CPU clock. Under a lower clock,
> I get less interrupts (what I was hoping for) and slightly less performance.
> Under higher clock, I get better performance and almost 1 interrupt per packet.

I have a patch that solves the high interrupt rate problem by keeping 
the driver in polled mode longer. It's written for the latest NAPI 
version that DaveM posted recently. I'll try to get some time to write 
it up and post it for comment.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

