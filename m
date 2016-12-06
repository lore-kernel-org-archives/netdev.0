From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH net-next 1/1] driver: ipvlan: Free the port memory
 directly with kfree instead of kfree_rcu
Date: Tue, 6 Dec 2016 15:00:41 +0800
Message-ID: <CA+6hz4oW=vfQdd-ReTrjjj6ZThuoqPB-y_=UwPzMMzUAMvDJpg@mail.gmail.com>
References: <1480998547-9013-1-git-send-email-fgao@ikuai8.com>
 <1481005511.18162.564.camel@edumazet-glaptop3.roam.corp.google.com>
 <CA+6hz4pGw-+HvKVDCiFmXRd6YwioUXdZfOghtx0aFb6EPxcj5A@mail.gmail.com> <1481007190.18162.570.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg65.qq.com ([103.7.28.233]:36466 "EHLO smtpbg65.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751690AbcLFHA6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 02:00:58 -0500
Received: from mail-ua0-f179.google.com (unknown [209.85.217.179])
        by esmtp4.qq.com (ESMTP) with SMTP id 0
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 15:00:43 +0800 (CST)
Received: by mail-ua0-f179.google.com with SMTP id 51so372832852uai.1
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 23:00:43 -0800 (PST)
In-Reply-To: <1481007190.18162.570.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Tue, Dec 6, 2016 at 2:53 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2016-12-06 at 14:31 +0800, Gao Feng wrote:
>
>> Because I don't fully hold the ipvlan codes now, I am afraid of that
>> there is someone which may get the port address when
>> ipvlan_port_destroy. So the original ipvlan_port_destroy uses the
>> kfree_rcu to avoid it.
>>
>> I am sure there is unnecessary to use kfree in ipvlan_port_create.
>
> And I am pretty sure it is unnecessary to use kfree_rcu() in
> ipvlan_port_destroy() as well.
>
> I highly suggest you spend time on learning why.
>
>
>

Thanks your suggestion.
I will send v2 patch after get the reason by myself.

Begards
Feng
