From: Vasily Averin <vvs@virtuozzo.com>
Subject: Re: [PATCH 3/3] ipmr_free_table() should be called under taken rtnl_lock
Date: Tue, 07 Jul 2015 20:53:19 +0300
Message-ID: <559C120F.7020709@virtuozzo.com>
References: <559BF613.7090904@virtuozzo.com>	<CAM_iQpW1zo4T3AyZsv7ofLLsFtAfnqzGuDcqcFKxw9uuRNk_vA@mail.gmail.com>	<559C0B7E.8010108@virtuozzo.com> <CAM_iQpX=_chUgfy39ifgKkygYKVnh-r9WXK4P6q70xR_Oczv=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:48983 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932286AbbGGRyU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jul 2015 13:54:20 -0400
In-Reply-To: <CAM_iQpX=_chUgfy39ifgKkygYKVnh-r9WXK4P6q70xR_Oczv=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07.07.2015 20:30, Cong Wang wrote:
> On Tue, Jul 7, 2015 at 10:25 AM, Vasily Averin <vvs@virtuozzo.com> wrote:
>> On 07.07.2015 20:13, Cong Wang wrote:
>>> On Tue, Jul 7, 2015 at 8:53 AM, Vasily Averin <vvs@virtuozzo.com> wrote:
>>>> ipmr_free_table() calls unregister_netdevice_many() inside
>>>> and changes net_todo_list protected by rtnl_lock
>>>
>>> Did you see any real bug?
>>
>> No, it was result of manual code review.
>>
>>> ipmr_free_table() is called in failure path, in this case there is no
>>> device registered yet, so unregister should be just a nop?
>>
>> However may be it's better to mark this place for future anyway?
> 
> Then add a comment there. ;)

As you can see I'm not familiar with this code,
so I would like to ask you to do it. :)
