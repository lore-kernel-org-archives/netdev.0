From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [RFC/PATCH 0/3] UDP memory usage accounting
Date: Thu, 27 Sep 2007 14:51:29 -0400
Message-ID: <46FBFBB1.2020503@redhat.com>
References: <46F3B67F.4030007@hitachi.com> <20070921125843.GA15810@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46664 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754835AbXI0Svm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 14:51:42 -0400
In-Reply-To: <20070921125843.GA15810@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Apologies for late response.

Evgeniy Polyakov wrote:
> Hi.
> 
> On Fri, Sep 21, 2007 at 09:18:07PM +0900, Satoshi OSHIMA (satoshi.oshima.fk@hitachi.com) wrote:
>> This patch set try to introduce memory usage accounting for
>> UDP(currently ipv4 only).
>>
>> Currently, memory usage of UDP can be observed as the sam of
>> usage of tx_queue and rx_queue. But I believe that the system
>> wide accounting is usefull when heavy loaded condition.
>>
>> In the next step, I would like to add memory usage quota
>> for UDP to avoid unlimited memory consumption problem
>> under DDOS attack.
> 
> Could you please desribed such attack in more details?
> Each UDP socket has its queue length which can not be exceeded
> (roughly), no new sockets are created when remote side sends a packet
> (like after special steps in TCP), so where is possibility to eat all
> the mem?

I think Satoshi will answer this question soon.

>> This patch set is for 2.6.23-rc7.
> 
> I seriously doubt you want to put udp specific hacks and zillions of
> atomic ops all around the code just to know exact number of bytes eaten
> for UDP.

I'll revise the patch to reduce the number of atomic operations.

> Please use udp specific code (like udp_sendmsg()) for proper accounting
> if you need that, but not hacks in generic ip code.

As far as I know, Satoshi is improving this part right now. Please wait his
response.

Many thanks for your comments.

Best regards,
Hideo Aoki

--
Hitachi Computer Products (America) Inc.
