From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: A problem about ICMP packet-too-big message handler
Date: Wed, 28 Jan 2015 18:07:08 +0800
Message-ID: <54C8B4CC.80309@huawei.com>
References: <54C78B8D.1070104@huawei.com> <1422434574.4678.21.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:26648 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754948AbbA1UP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 15:15:27 -0500
In-Reply-To: <1422434574.4678.21.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/1/28 16:42, Hannes Frederic Sowa wrote:
> On Di, 2015-01-27 at 20:58 +0800, Yang Yingliang wrote:
>> Hi,
>>
>> My kernel is 3.10 LTS.
>>
>> I got a problem here about handling ICMP packet-too-big message.
>>
>> Before sending a packet-too-big packet :
>>
>> # ip -6 route list table local
>> local ::1 dev lo  metric 0 
>> local fe80:: dev lo  metric 0 
>> local fe80:: dev lo  metric 0 
>> local fe80:: dev lo  metric 0 
>> local fe80:: dev lo  metric 0 
>> local fe80:: dev lo  metric 0 
>> local fe80:: dev lo  metric 0 
>> local fe80::1 dev lo  metric 0 	//It  does not have expire value
> 
> Did you just add a local route or do you also have a corresponding IPv6
> address bound to loopback?

I just set a IPv6 linklocal address and the route was added automatic.
I do not add any other route by hand.

Regards,
Yang
