From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2 net-next 0/7] net: speedup netns create/delete time
Date: Tue, 26 Sep 2017 08:30:03 -0700
Message-ID: <CANn89iKq86_FRaL7Y3Ekhf_JD8NY2s8PWibGN+WdmJL1TsPXJA@mail.gmail.com>
References: <20170919232709.14690-1-edumazet@google.com> <8edb310a-562d-bff1-0482-64314833e722@mellanox.com>
 <CANn89i+LE6He_E3VHwUTpLAVW+uUGo+FPs_zg1bs4P3CVcCL6Q@mail.gmail.com>
 <266d30e7-5164-48e8-b802-56bb93558823@mellanox.com> <CANn89iJ4io_gX-V8A4hE04cH=czGZYs8WGBOpaiBpWMMHOgVVw@mail.gmail.com>
 <33E69A03-6594-423A-86E6-02029046BE7D@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tariq Toukan <tariqt@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Majd Dibbiny <majd@mellanox.com>,
        Yonatan Cohen <yonatanc@mellanox.com>,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f178.google.com ([209.85.161.178]:53345 "EHLO
        mail-yw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934460AbdIZPaF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 11:30:05 -0400
Received: by mail-yw0-f178.google.com with SMTP id x131so7326408ywa.10
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 08:30:05 -0700 (PDT)
In-Reply-To: <33E69A03-6594-423A-86E6-02029046BE7D@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 8:22 AM, Dmitry Torokhov
<dmitry.torokhov@gmail.com> wrote:

> It is in Greg's tree where all kobject patches should go through as far as I know.

Yes, I will fix this, adding a second memmove()
