From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: Re: [next-queue PATCH 2/3] net/sched: Introduce Credit Based Shaper (CBS) qdisc
Date: Thu, 28 Sep 2017 16:07:25 -0700
Message-ID: <87ing2fmmq.fsf@intel.com>
References: <20170926233916.11774-1-vinicius.gomes@intel.com> <20170926233916.11774-3-vinicius.gomes@intel.com> <CAM_iQpVrz+e=TYHYqaYyUWRP528GSZXx8EnN1yPhZK8eLvP4Yw@mail.gmail.com> <87lgkzg7xv.fsf@intel.com> <CAM_iQpUUUrYeyqYK-CDAXzuKcy9FDtq_etQQvO4D4uCjV6As-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>, andre.guedes@intel.com,
        Ivan Briano <ivan.briano@intel.com>,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com,
        richardcochran@gmail.com, Henrik Austad <henrik@austad.us>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:49864 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750857AbdI1XH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 28 Sep 2017 19:07:26 -0400
In-Reply-To: <CAM_iQpUUUrYeyqYK-CDAXzuKcy9FDtq_etQQvO4D4uCjV6As-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Cong Wang <xiyou.wangcong@gmail.com> writes:

[...]

>>>
>>> I am not sure how we can solve this elegantly, perhaps you should
>>> extend mqprio rather than add a new one?
>>
>> Is the alternative hinted in the FIXME worse? Instead of passing the
>> index of the hardware queue to the driver we pass the pointer to a
>> netdev_queue to the driver and it "discovers" the HW queue from that.
>
> Does this way solve the dependency on mqprio? If yes then it is good.
> And you have to fix it before merge, we don't have any qdisc depending
> a specific type of qdisc to be its parent.

Yes, it does. And if we do like Jesus pointed out, we can do this on the
CBS qdisc side, no need to change the driver.


Cheers,
