From: Alexander Graf <agraf@suse.de>
Subject: Re: [PATCH v8 3/3] net: hisilicon: new hip04 ethernet driver
Date: Sun, 07 Dec 2014 10:49:12 +0100
Message-ID: <54842298.2010007@suse.de>
References: <1397869980-21187-1-git-send-email-zhangfei.gao@linaro.org> <1397869980-21187-4-git-send-email-zhangfei.gao@linaro.org> <5483A279.5000503@suse.de> <5483C977.2060308@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux@arm.linux.org.uk, arnd@arndb.de,
	f.fainelli@gmail.com, sergei.shtylyov@cogentembedded.com,
	mark.rutland@arm.com, David.Laight@ACULAB.COM,
	eric.dumazet@gmail.com, xuwei5@hisilicon.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>,
	Zhangfei Gao <zhangfei.gao@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:37508 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752795AbaLGJtQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Dec 2014 04:49:16 -0500
In-Reply-To: <5483C977.2060308@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 07.12.14 04:28, Ding Tianhong wrote:
> On 2014/12/7 8:42, Alexander Graf wrote:
>> On 19.04.14 03:13, Zhangfei Gao wrote:
>>> Support Hisilicon hip04 ethernet driver, including 100M / 1000M controller.
>>> The controller has no tx done interrupt, reclaim xmitted buffer in the poll.
>>>
>>> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
>>
>> Is this driver still supposed to go upstream? I presume this was the
>> last submission and it's been quite some time ago :)
>>
> 
> yes, it is really a long time, but The hip04 did not support tx irq, 
> we couldn't get any better idea to fix this defect, do you have any suggestion?

Well, if hardware doesn't have a TX irq I don't see there's anything we
can do to fix that ;).

Dave, what's your take here? Should we keep a driver from going upstream
just because the hardware is partly broken? I'd really prefer to have an
upstream driver on that SoC rather than some random (eventually even
more broken) downstream code.


Alex
