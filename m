From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH v4 0/2] l2 hardware accelerated macvlans
Date: Mon, 11 Nov 2013 09:16:24 -0800
Message-ID: <528110E8.8040708@intel.com>
References: <20131106175308.3822.73239.stgit@jf-dev1-dcblab> <527C662B.4080300@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, davem@davemloft.net,
	alexander.h.duyck@intel.com, andy@greyhouse.net,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	vyasevich@gmail.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16965 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753173Ab3KKRQZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Nov 2013 12:16:25 -0500
In-Reply-To: <527C662B.4080300@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/7/2013 8:18 PM, Vlad Yasevich wrote:

[...]

>> If folks find this series acceptable there are a few
>> items we can work on next. First broadcast and multicast
>> will use the hardware even for local traffic with this
>> series. It would be best (I think) to use the software
>> path for macvlan to macvlan traffic and save the PCIe
>> bus. This depends on how much you value CPU time vs
>> PCIE bandwidth. This will need another patch series
>> to flush out.
>>
>
> John
>
> So, I've been looking at these patches and the more I
> look the more I wonder how much benefit there is in
> sending unicast macvlan<->macvlan traffic through the hw.
> It looks like any bulk transfers would have to undergo
> tso segmentaion and GRO, where as this can be completely
> bypassed right now with software.
>
> Did you run any numbers?
>

I have run some numbers on previous versions of the code for
this. I'll take some new ones with the final code today/tomorrow
and post them.

Just wanted to let you know I saw this...

Thanks,
John

> Thanks
> -vlad
>
>
