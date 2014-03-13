From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] bcm63xx_enet: Stop pretending to support netpoll
Date: Thu, 13 Mar 2014 12:42:22 -0700
Message-ID: <CAGVrzcYFy5wr0fvdsLdo7G0GC-kmJ-tjR=sG70hFMJK5oYcr4A@mail.gmail.com>
References: <87wqg0cy9d.fsf@xmission.com> <20140311.160931.1395978386605601765.davem@davemloft.net>
 <87ppls774g.fsf_-_@xmission.com> <20140313.152616.852706173032905275.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ebiederm@xmission.com, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:48390 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754884AbaCMTnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 15:43:04 -0400
Received: by mail-pb0-f42.google.com with SMTP id rr13so1577651pbb.29
        for <netdev@vger.kernel.org>; Thu, 13 Mar 2014 12:43:03 -0700 (PDT)
In-Reply-To: <20140313.152616.852706173032905275.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-03-13 12:26 GMT-07:00 David Miller <davem@davemloft.net>:
> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Tue, 11 Mar 2014 14:33:35 -0700
>
>> bcm_enet_netpoll does not exist, and causing
>> bcm63xx_net to fail to build when NET_POLL_CONTROLLER
>> is defined.
>>
>> Remove the bogus .ndo_poll_controller = bcm_enet_netpoll
>>
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>
> Applied.
>
> This driver doesn't get a lot of build testing, and that's due to the
> platform BCM63XX kconfig option it depends upon.  Probably it should
> be exposed more widely to perhaps a more broad dependency such as
> CONFIG_OF.

There is no OF-aware platform using that driver. Part of the reason
why it does not get much build coverage is the large header
dependencies provided by arch/mips/include/asm/mach-bcm63xx. I will
work on improving that.
-- 
Florian
