From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: Re: Resource usages in Linux drivers
Date: Thu, 23 Apr 2015 17:29:05 +0800
Message-ID: <5538BB61.30907@163.com>
References: <5538950F.3040405@163.com> <5538B938.9060607@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	Neil Horman <nhorman@tuxdriver.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-12.163.com ([220.181.12.12]:47004 "EHLO m12-12.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751590AbbDWJcM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2015 05:32:12 -0400
In-Reply-To: <5538B938.9060607@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you!

On 04/23/2015 05:19 PM, Sergei Shtylyov wrote:
> Hello.
>
> On 4/23/2015 9:45 AM, Jia-Ju Bai wrote:
>
>> Dear Sir,
>
>> I am very sorry to trouble you.
>
>> I find that resource management is error-prone when writing Linux 
>> drivers, and
>> many problems may occur, such as resource leaks.
>> Meanwhile, I find that many applied patches in the kernel mailing 
>> list focus
>> on releasing allocated resources, especially in error-handling paths.
>
>> Therefore, I have a question: is it possible to automatically release
>> allocated resources in drivers before unloading and in error-handling 
>> paths?
>
>    Yes, there's managed device API, look for functions starting with 
> devm_.
> There's one limitation though: it can be used only in the driver's 
> probe() method, so can't be used when e.g. network device is being 
> opened.
I think many APIs, such as kmalloc, can also be managed like garbage 
collection in Java.
Maybe the performance is a matter.

>
>> I am looking forward to your reply, thanks!
>
>    Such questions should actually be asked on the mailing lists, not 
> personally.
>
I am sorry for that, and I will cc to the mailing lists and other 
maintainers.
