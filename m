From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: Re: Resource usages in Linux drivers
Date: Thu, 23 Apr 2015 18:08:35 +0800
Message-ID: <5538C4A3.6080302@163.com>
References: <5538950F.3040405@163.com> <5538B938.9060607@cogentembedded.com> <5538BB61.30907@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	Neil Horman <nhorman@tuxdriver.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:42010 "EHLO m12-13.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932132AbbDWKJ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2015 06:09:26 -0400
In-Reply-To: <5538BB61.30907@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2015 05:29 PM, Jia-Ju Bai wrote:
> Thank you!
>
> On 04/23/2015 05:19 PM, Sergei Shtylyov wrote:
>> Hello.
>>
>> On 4/23/2015 9:45 AM, Jia-Ju Bai wrote:
>>
>>> Dear Sir,
>>
>>> I am very sorry to trouble you.
>>
>>> I find that resource management is error-prone when writing Linux 
>>> drivers, and
>>> many problems may occur, such as resource leaks.
>>> Meanwhile, I find that many applied patches in the kernel mailing 
>>> list focus
>>> on releasing allocated resources, especially in error-handling paths.
>>
>>> Therefore, I have a question: is it possible to automatically release
>>> allocated resources in drivers before unloading and in 
>>> error-handling paths?
>>
>>    Yes, there's managed device API, look for functions starting with 
>> devm_.
>> There's one limitation though: it can be used only in the driver's 
>> probe() method, so can't be used when e.g. network device is being 
>> opened.
> I think many APIs, such as kmalloc, can also be managed like garbage 
> collection in Java.
> Maybe the performance is a matter.
>
>>
>>> I am looking forward to your reply, thanks!
>>
>>    Such questions should actually be asked on the mailing lists, not 
>> personally.
>>
> I am sorry for that, and I will cc to the mailing lists and other 
> maintainers.
>
>

I find that some common APIs are not managed, such as napi_enable and 
napi_start_queue. Is it possible to provide managed APIs for them?
I also find many drivers do not use these managed APIs, especially in 
ethernet card drivers (like e100, r8169). Is it possible to change them?


Best wishes,
Jia-Ju Bai
