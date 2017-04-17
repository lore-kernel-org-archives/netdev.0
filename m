From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: IGMP on IPv6
Date: Mon, 17 Apr 2017 14:38:48 -0700
Message-ID: <CAM_iQpWYuQdxF0AOEMHRy7BSmxMVUb-7w7OdgYeOKe6atATsFQ@mail.gmail.com>
References: <1479111388-25383-1-git-send-email-liuhangbin@gmail.com>
 <58D29265.1020604@ti.com> <58EFA913.5060604@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hangbin Liu <liuhangbin@gmail.com>,
        "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37356 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753619AbdDQVjK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 17:39:10 -0400
Received: by mail-wm0-f52.google.com with SMTP id u2so40522910wmu.0
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 14:39:09 -0700 (PDT)
In-Reply-To: <58EFA913.5060604@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thu, Apr 13, 2017 at 9:36 AM, Murali Karicheri <m-karicheri2@ti.com> wrote:
> On 03/22/2017 11:04 AM, Murali Karicheri wrote:
>> This is going directly to the slave Ethernet interface.
>>
>> When I put a WARN_ONCE, I found this is coming directly from
>> mld_ifc_timer_expire() -> mld_sendpack() -> ip6_output()
>>
>> Do you think this is fixed in latest kernel at master? If so, could
>> you point me to some commits.
>>
>>
> Ping... I see this behavior is also seen on v4.9.x Kernel. Any clue if
> this is fixed by some commit or I need to debug? I see IGMPv6 has some
> fixes on the list to make it similar to IGMPv4. So can someone clarify this is
> is a bug at IGMPv6 code or I need to look into the HSR driver code?
> Since IGMPv4 is going over the HSR interface I am assuming this is a
> bug in the IGMPv6 code. But since I have not experience with this code
> can some expert comment please?
>

How did you configure your network interfaces and IPv4/IPv6 multicast?
IOW, how did you reproduce this? For example, did you change your
HSR setup when this happened since you mentioned
NETDEV_CHANGEUPPER?
