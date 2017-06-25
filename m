From: Wei Wang <weiwan@google.com>
Subject: Re: [PATCH v3 net] net: ipv6: reset daddr and dport in sk if
 connect() fails
Date: Sun, 25 Jun 2017 13:47:53 -0700
Message-ID: <CAEA6p_AScKpmjBCKK4Eg=UNtAde2oti9ymXGcnkCW4fvmC9KKg@mail.gmail.com>
References: <20170623222537.130493-1-tracywwnj@gmail.com> <20170625.114651.1973887687669104262.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?B?546L6JSa?= <tracywwnj@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
        Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:36095 "EHLO
        mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751343AbdFYUrz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2017 16:47:55 -0400
Received: by mail-vk0-f47.google.com with SMTP id y70so32057731vky.3
        for <netdev@vger.kernel.org>; Sun, 25 Jun 2017 13:47:54 -0700 (PDT)
In-Reply-To: <20170625.114651.1973887687669104262.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 25, 2017 at 8:46 AM, David Miller <davem@davemloft.net> wrote:
> From: Wei Wang <tracywwnj@gmail.com>
> Date: Fri, 23 Jun 2017 15:25:37 -0700
>
>> From: Wei Wang <weiwan@google.com>
>>
>> In __ip6_datagram_connect(), reset sk->sk_v6_daddr and inet->dport if
>> error occurs.
>> In udp_v6_early_demux(), check for sk_state to make sure it is in
>> TCP_ESTABLISHED state.
>> Together, it makes sure unconnected UDP socket won't be considered as a
>> valid candidate for early demux.
>>
>> Fixes: 5425077d73e0 ("net: ipv6: Add early demux handler for UDP unicast=
")
>>
>> v3: add TCP_ESTABLISHED state check in udp_v6_early_demux()
>> v2: fix compilation error
>>
>> Signed-off-by: Wei Wang <weiwan@google.com>
>> Acked-by: Maciej =C5=BBenczykowski <maze@google.com>
>
> Please don't format the tag area like this, if you want to put a change
> log put it first.
>
> Then put all of the tags (Fixes:, Signed-off-by:, Acked-by:, etc.)
> together with no empty line separators, at the end.
>
> I fixed it up this time.
>
> Applied and queued up for -stable, thanks.

Got it. Will note it down.
Thanks for taking care of it.

Wei
