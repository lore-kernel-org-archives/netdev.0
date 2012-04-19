From: Massimo Cetra <mcetra@navynet.it>
Subject: Re: [PATCH] set fake_rtable's dst to NULL to avoid kernel Oops.
Date: Thu, 19 Apr 2012 09:58:39 +0200
Message-ID: <4F8FC5AF.7020403@navynet.it>
References: <000001cd1c62$75d10de0$617329a0$%huangpeng@huawei.com> <20120418190450.GA30185@burratino>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Peter Huang (Peng)" <peter.huangpeng@huawei.com>,
	shemminger@vyatta.com, "'David S. Miller'" <davem@davemloft.net>,
	netdev@vger.kernel.org, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, ctrix+debianbugs@navynet.it,
	peter.huangpeng@gmail.com, harry.majun@huawei.com
To: Jonathan Nieder <jrnieder@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host188-6-static.238-77-b.business.telecomitalia.it ([77.238.6.188]:51451
	"EHLO max.ctrix.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574Ab2DSIEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 04:04:48 -0400
In-Reply-To: <20120418190450.GA30185@burratino>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/04/2012 21:04, Jonathan Nieder wrote:
>
> Massimo Cetra (cc-ed) tested the patch against a 3.2.y kernel and wrote[1]:
>
>> The patch i applied yesterday to the debian kernel has been installed
>> and the kernel is not panic-ing anymore.
>>
>> I'll try to keep this bug up to date.
>
> So it seems to work.  Dave, please consider queuing this for stable@
> when the final patch is ready.

Also please consider that the bridge problems are not over and the 
kernel keeps panicing in a different way...

- http://marc.info/?t=133474395500004&r=1&w=2

Thanks,
Massimo
