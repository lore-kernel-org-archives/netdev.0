From: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v13 0/3] add hisilicon hip04 ethernet driver
Date: Thu, 15 Jan 2015 20:56:21 +0800
Message-ID: <54B7B8F5.6060808@huawei.com>
References: <1421217254-12008-1-git-send-email-dingtianhong@huawei.com> <54B642B4.8010807@suse.de> <54B77C43.6010200@huawei.com> <14674609.dERhba4yMV@wuerfel> <54B7B4E7.8030108@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
To: Alexander Graf <agraf-l3A5Bk7waGM@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54B7B4E7.8030108-l3A5Bk7waGM@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2015/1/15 20:39, Alexander Graf wrote:
> 
> 
> On 15.01.15 10:42, Arnd Bergmann wrote:
>> On Thursday 15 January 2015 16:37:23 Ding Tianhong wrote:
>>> On 2015/1/14 18:19, Alexander Graf wrote:
>>>>
>>>> >From a 10000 feet perspective it looks like two problems to me
>>>>
>>>>   1) Allocation failure doesn't get handled properly somewhere
>>
>> This is the bug that Eric pointed out as well.
>>
>>>>   2) We fail to allocate with order=0 - I don't see why
>>
>> GFP_ATOMIC. When allocating from a the napi poll function in softirq
>> context, you have to use nonblocking allocations, which occasionally
>> fail. This should not cause any harm other than dropped packets.
>>
>>> is it easy to repetition this bug? how big is your memory on your board,
>>> is it happened in your previous hip04 driver?
>>
>> It should be independent of memory size, but may be more likely if you
>> don't have swap space configured.
> 
> With the previous driver I was unable to get this far - I ended up in
> random memory corruption and had a ~90% packet loss after about an hour
> of uptime.
> 
> I'm not sure whether it's easy to reproduce, I merely started up a few
> VMs, did some disk I/O and started to compile QEMU in the background ;).
> 
> I'll happily give your follow up patch that's going to fix the memory
> allocation problems a try though.
> 
Thanks for your work, I am sure we could make it much more better:)

Ding

> 
> Alex
> 
> .
> 


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
