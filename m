From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 3/3] ipmr_free_table() should be called under taken rtnl_lock
Date: Tue, 7 Jul 2015 10:30:36 -0700
Message-ID: <CAM_iQpX=_chUgfy39ifgKkygYKVnh-r9WXK4P6q70xR_Oczv=g@mail.gmail.com>
References: <559BF613.7090904@virtuozzo.com>
	<CAM_iQpW1zo4T3AyZsv7ofLLsFtAfnqzGuDcqcFKxw9uuRNk_vA@mail.gmail.com>
	<559C0B7E.8010108@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Vasily Averin <vvs@virtuozzo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:36164 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932484AbbGGRai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 13:30:38 -0400
Received: by oiaf66 with SMTP id f66so115291475oia.3
        for <netdev@vger.kernel.org>; Tue, 07 Jul 2015 10:30:36 -0700 (PDT)
In-Reply-To: <559C0B7E.8010108@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 7, 2015 at 10:25 AM, Vasily Averin <vvs@virtuozzo.com> wrote:
> On 07.07.2015 20:13, Cong Wang wrote:
>> On Tue, Jul 7, 2015 at 8:53 AM, Vasily Averin <vvs@virtuozzo.com> wrote:
>>> ipmr_free_table() calls unregister_netdevice_many() inside
>>> and changes net_todo_list protected by rtnl_lock
>>
>> Did you see any real bug?
>
> No, it was result of manual code review.
>
>> ipmr_free_table() is called in failure path, in this case there is no
>> device registered yet, so unregister should be just a nop?
>
> However may be it's better to mark this place for future anyway?

Then add a comment there. ;)
