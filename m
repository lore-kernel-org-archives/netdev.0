From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] net: add support for netdev notifier error injection
Date: Tue, 1 Dec 2015 00:49:55 +0100
Message-ID: <565CE0A3.2010403@cumulusnetworks.com>
References: <1448714728-12729-1-git-send-email-razor@blackwall.org>
 <CAC5umyjONtF9r=Ox1-mMS-vzxp2j-fk+VX1wWWVvWvyOxWPbiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, shm@cumulusnetworks.com,
	gospo@cumulusnetworks.com, roopa@cumulusnetworks.com,
	dsa@cumulusnetworks.com, "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Akinobu Mita <akinobu.mita@gmail.com>,
	Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAC5umyjONtF9r=Ox1-mMS-vzxp2j-fk+VX1wWWVvWvyOxWPbiQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/01/2015 12:48 AM, Akinobu Mita wrote:
> 2015-11-28 21:45 GMT+09:00 Nikolay Aleksandrov <razor@blackwall.org>:
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>
>> This module allows to insert errors in some of netdevice's notifier
>> events. All network drivers use these notifiers to signal various events
>> and to check if they are allowed, e.g. PRECHANGEMTU and CHANGEMTU
>> afterwards. Until recently I had to run failure tests by injecting
>> a custom module, but now this infrastructure makes it trivial to test
>> these failure paths. Some of the recent bugs I fixed were found using
>> this module.
>> Here's an example:
>>  $ cd /sys/kernel/debug/notifier-error-inject/netdev
>>  $ echo -22 > actions/NETDEV_CHANGEMTU/error
>>  $ ip link set eth0 mtu 1024
>>  RTNETLINK answers: Invalid argument
> 
> This patch looks good to me.  It would be nice if you add tools like
> tools/testing/selftests/cpu-hotplug/cpu-on-off-test.sh for this feature.
> 

Thanks for reviewing and noted. I'll take a look and make some tests.
Do you mind if I post it as a follow-up ?

Cheers,
 Nik
