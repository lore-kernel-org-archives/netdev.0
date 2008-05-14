From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] [SCTP]: Add address type check while process paramaters
 of ASCONF chunk
Date: Wed, 14 May 2008 09:49:20 +0800
Message-ID: <482A4520.6010103@cn.fujitsu.com>
References: <48298E27.40100@hp.com>	<20080513.153238.211668684.davem@davemloft.net>	<482A38B5.5030908@cn.fujitsu.com> <20080513.181415.228379595.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, kaber@trash.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51295 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752173AbYENBtF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 21:49:05 -0400
In-Reply-To: <20080513.181415.228379595.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Wei Yongjun <yjwei@cn.fujitsu.com>
> Date: Wed, 14 May 2008 08:56:21 +0800
>
>   
>> Hi David:
>>
>>  Sorry for my mistake. This patch is create and tested by me.
>>
>>  I tested it used a test tool which is created by me. And this patchset 
>> resolved the kernel panic problem. It seems that I need to do more 
>> review my patch and
>> add more test case to my tool. I will pay more attention to do the 
>> correct patchs.
>>     
>
> It dereferences an uninitialized pointer, unconditionally.  Therefore,
> the patch was definitely completely untested.  This function never ran
> during your tests.
>
> Please, no more excuses.
>
> You didn't test the patch.
> The end.
>   

Are you sure you are right?

First I am sorry for stupid patch, second I said again, I do test it, 
but do not enough test.

uninitialized pointer is not NULL pointer, so it not kernel panic when 
use "addr_param->v4.param_hdr.type", this patch cause function alaways 
return SCTP_ERROR_INV_PARAM error, so even if I add IPv6 address to peer 
which not supported IPv6 address or add IPv4 address to peer which not 
supported IPv4 address is returned SCTP_ERROR_INV_PARAM, and passed my 
test case.
I not do test add IPv4/IPv6 address to peer which supported IPv4/IPv6 
address, this is my fault .






