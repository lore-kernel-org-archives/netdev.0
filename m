From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] ipv4: disable BH in set_ping_group_range()
Date: Thu, 20 Oct 2016 12:40:07 -0700
Message-ID: <CAM_iQpVBHa2ujKN1hsU0LT+g899+WEy9a1oBgDj1FmpifPmz6g@mail.gmail.com>
References: <1476984408.7065.21.camel@edumazet-glaptop3.roam.corp.google.com> <CAM_iQpVFQD0Oqf8YO9HybDpPMhzMMK5m_wNyLwTfVpEwpAVBNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Eric Salo <salo@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:38170 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756531AbcJTTke (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 15:40:34 -0400
Received: by mail-it0-f46.google.com with SMTP id 66so108689922itl.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 12:40:34 -0700 (PDT)
In-Reply-To: <CAM_iQpVFQD0Oqf8YO9HybDpPMhzMMK5m_wNyLwTfVpEwpAVBNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 20, 2016 at 12:32 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, Oct 20, 2016 at 10:26 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> In commit 4ee3bd4a8c746 ("ipv4: disable BH when changing ip local port
>> range") Cong added BH protection in set_local_port_range() but missed
>> that same fix was needed in set_ping_group_range()
>
> Don't know why ping_group_range shares the same lock with local_port_range...
> Perhaps just for saving a few bytes, but that is why I missed this place.

Hold on... We clearly have typos there... Your fix is not correct.
