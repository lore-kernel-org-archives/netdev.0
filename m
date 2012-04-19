From: "Peter Huang(Peng)" <peter.huangpeng@huawei.com>
Subject: Re: [PATCH v3] set fake_rtable's dst to NULL to avoid kernel Oops.
Date: Thu, 19 Apr 2012 16:58:47 +0800
Message-ID: <4F8FD3C7.2030006@huawei.com>
References: <4F8F77F5.8020201@huawei.com>
 <20120418234649.0bcb3872@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org,
	ctrix+debianbugs@navynet.it, Eric Dumazet <eric.dumazet@gmail.com>,
	harry.majun@huawei.com, linux-kernel@vger.kernel.org,
	peter.huangpeng@gmail.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:58225 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751699Ab2DSI7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 04:59:15 -0400
In-reply-to: <20120418234649.0bcb3872@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012/4/19 14:46, Stephen Hemminger wrote:
> On Thu, 19 Apr 2012 10:27:01 +0800
> "Peter Huang(Peng)"<peter.huangpeng@huawei.com>  wrote:
>
>> When bridge is deleted before tap/vif device's delete, kernel may
>> encounter an oops because of NULL reference to fake_rtable's dst.
>> Set fake_rtable's dst to NULL before sending packets out can solve this
>> problem.
>>
>> v3 enrich commit header
>>
>> v2 added a new flag DST_FAKE_RTABLE to dst_entry struct.
>>
>>
>> Acked-by: Eric Dumazet<eric.dumazet@gmail.com>
>> Signed-off-by: Peter Huang<peter.huangpeng@huawei.com>
>
> I am okay with the contents of the patch but the formatting is all
> botched. It adds bad indentation and whitespace, please run it
> through checkpatch.

Got it, I will send the v4 version of modified format.
Thanks!
