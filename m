From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: A problem about ICMP packet-too-big message handler
Date: Wed, 28 Jan 2015 14:46:43 +0800
Message-ID: <54C885D3.70808@huawei.com>
References: <54C78B8D.1070104@huawei.com> <20150128051929.GA3369592@devbig242.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Martin Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:24516 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760671AbbA1GrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 01:47:07 -0500
In-Reply-To: <20150128051929.GA3369592@devbig242.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/1/28 13:19, Martin Lau wrote:
> On Tue, Jan 27, 2015 at 08:58:53PM +0800, Yang Yingliang wrote:
>> Hi,
>>
>> My kernel is 3.10 LTS.
>>
>> I got a problem here about handling ICMP packet-too-big message.
>>
>> Before sending a packet-too-big packet :
> The expires should be set by the host _receiving_ the icmpv6 too-big.
> 
> Can you spell out some details of the outgoing icmpv6 too-big packet?
> like, the src/dst ip of the icmpv6 and the original ip packet that triggered the
> too-big.
> 

I don't send too-big packet to trigger the err handling.

I just only send a ICMPv6 packet which type is ICMPV6_PKT_TOOBIG.
