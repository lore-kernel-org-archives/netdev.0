From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net] ip6_tunnel: remove unreachable ICMP_REDIRECT code
Date: Tue, 9 May 2017 11:25:06 +0800
Message-ID: <CAPwn2JQp=UZx+ZEUWxPhiiLBkCGoVQq1VJ_ctTHSnowwXQJOWA@mail.gmail.com>
References: <1494241863-32549-1-git-send-email-liuhangbin@gmail.com> <20170508.155903.61649135414142419.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:35119 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751166AbdEIDZH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 23:25:07 -0400
Received: by mail-it0-f45.google.com with SMTP id c15so79263338ith.0
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 20:25:07 -0700 (PDT)
In-Reply-To: <20170508.155903.61649135414142419.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-05-09 3:59 GMT+08:00 David Miller <davem@davemloft.net>:
> From: Hangbin Liu <liuhangbin@gmail.com>
> Date: Mon,  8 May 2017 19:11:03 +0800
>
>> After call ip6_tnl_err(), the rel_type will be ether ICMPV6_DEST_UNREACH
>> or ICMPV6_PKT_TOOBIG. We will never reach ICMP_REDIRECT. So remove it.
>>
>> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
>
> Your patches here, all seemingly due to "visual inspection", are starting
> to really, truly, irritate me.

Yes, this is based on the coverity scan result.  I'm really sorry to make
you feel uncomfortable and I apologize for this.  I trust the result too much
and did not do enough research. I will try my best to make sure the patch
really improve or fix something next time.

Sorry again.

Regards
Hangbin

>
> Half of them are unnecessary, some are completely buggy.
>
> I have to review them and audit them very satrictly as a result, and
> this takes up an unnecessarily large amount of my time.
>
> Therefore, I'm basically going to stop looking at your changes _unless_
> you can show that you specifically tested and exercised all of the code
> paths you are changing.
>
> I am sorry to have to do this, but the value to effort ratio of
> reviewing and integrating your changes is quite poor.
