From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] ip[6]: don't register inet[6]dev when dev is down
Date: Mon, 10 Jul 2017 10:19:22 +0200
Message-ID: <a9c2cd47-98dc-fd14-1a50-86708d4c025d@6wind.com>
References: <20170705155725.15469-1-nicolas.dichtel@6wind.com>
 <20170708.110234.1001958921525251511.davem@davemloft.net>
 <CAM_iQpU21rUQ9JWb8qzTs=V+bGC1TZ1HaWC-t1GkUqu5Ymdoxw@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Hongjun Li <hongjun.li@6wind.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:33352 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752454AbdGJITX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 04:19:23 -0400
Received: by mail-lf0-f54.google.com with SMTP id z78so53732406lff.0
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 01:19:22 -0700 (PDT)
In-Reply-To: <CAM_iQpU21rUQ9JWb8qzTs=V+bGC1TZ1HaWC-t1GkUqu5Ymdoxw@mail.gmail.com>
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/07/2017 à 20:44, Cong Wang a écrit :
> On Sat, Jul 8, 2017 at 3:02 AM, David Miller <davem@davemloft.net> wrote:
[snip]
>> Can you show exactly why the procfs state isn't cleaned up for
>> these devices moving between namespaces?  Maybe that is the real
>> bug and a better place to fix this.
>>
> 
> It is because the ipv6_add_dev() adds these proc files back after
> NETDEV_UNREGISTER event.
> 
Yep, that was the initial problem.


Regards,
Nicolas
