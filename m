From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2 net-next 0/7] net: speedup netns create/delete time
Date: Thu, 19 Oct 2017 07:11:03 -0700
Message-ID: <CANn89iKiKvzz6_R+T4kO8ztXFC7ke299+vOsGr92q2NfGBwFjw@mail.gmail.com>
References: <20170919232709.14690-1-edumazet@google.com> <8edb310a-562d-bff1-0482-64314833e722@mellanox.com>
 <CANn89i+LE6He_E3VHwUTpLAVW+uUGo+FPs_zg1bs4P3CVcCL6Q@mail.gmail.com>
 <266d30e7-5164-48e8-b802-56bb93558823@mellanox.com> <CANn89iJ4io_gX-V8A4hE04cH=czGZYs8WGBOpaiBpWMMHOgVVw@mail.gmail.com>
 <33E69A03-6594-423A-86E6-02029046BE7D@gmail.com> <CANn89iKq86_FRaL7Y3Ekhf_JD8NY2s8PWibGN+WdmJL1TsPXJA@mail.gmail.com>
 <be222d71-0b61-9256-6d39-cbb9d762cd22@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Majd Dibbiny <majd@mellanox.com>,
        Yonatan Cohen <yonatanc@mellanox.com>,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:43447 "EHLO
        mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754235AbdJSOLE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 10:11:04 -0400
Received: by mail-yw0-f173.google.com with SMTP id y75so3595436ywg.0
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 07:11:04 -0700 (PDT)
In-Reply-To: <be222d71-0b61-9256-6d39-cbb9d762cd22@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 4:48 AM, Tariq Toukan <tariqt@mellanox.com> wrote:
>
> Hi Eric,
>
> I just wanted to check if this is solved already, as I don't want to keep an
> unnecessary revert patch in our internal branches.
> According to my check bug still exists.
>
I will handle this today, thanks for the reminder.
