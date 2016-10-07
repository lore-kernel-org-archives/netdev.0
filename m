From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] ipv6 addrconf: disallow rtr_solicits < -1
Date: Thu, 6 Oct 2016 17:53:19 -0700
Message-ID: <CAM_iQpX7VUwey0gyjei9WLvXcs1pHidQUqvGW8rhpq-qC2PcXw@mail.gmail.com>
References: <1475476917-17382-1-git-send-email-zenczykowski@gmail.com>
 <20161004.003831.2056791273400961514.davem@davemloft.net> <CANP3RGdVquyFe1VA2mKMC1HNgnXPhmpsv45R-7P6boWCb8oC2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        Linux NetDev <netdev@vger.kernel.org>,
        Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:36039 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753266AbcJGAxk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 20:53:40 -0400
Received: by mail-it0-f52.google.com with SMTP id l13so2627079itl.1
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2016 17:53:40 -0700 (PDT)
In-Reply-To: <CANP3RGdVquyFe1VA2mKMC1HNgnXPhmpsv45R-7P6boWCb8oC2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 3, 2016 at 11:40 PM, Maciej =C5=BBenczykowski
<zenczykowski@gmail.com> wrote:
>> Please remove the const qualifier and the casts to be consistent
>> with how we handle this elsewhere.
>>
>> Thanks.
>
> I can of course trivially make that change.
>
> But:
>
> (on net-next/master)
> git grep 'extra[12].*=3D.*\(void *[*]\)'
>
> currently finds 45 matches, and this patch adds a 46th.

Seems the sysctl layer should make them const, but I never look
into it, it doesn't look like it needs to modify these min/max consts.
