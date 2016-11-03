From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH net-next v2 1/1] driver: veth: Refine the statistics codes
 of veth driver
Date: Thu, 3 Nov 2016 23:13:00 +0800
Message-ID: <CA+6hz4r_9CPirG5H5QBgpzeE0Coee34RNmAr6jqW1vt3s4YDMg@mail.gmail.com>
References: <1478178237-23020-1-git-send-email-fgao@ikuai8.com>
 <1478179858.7065.438.camel@edumazet-glaptop3.roam.corp.google.com>
 <CA+6hz4r9zkPp7-mG7b98ocPvjTiheSnEBMjffSkLXD1MM-aMtg@mail.gmail.com>
 <1478183516.7065.440.camel@edumazet-glaptop3.roam.corp.google.com>
 <CA+6hz4owi2WgeGWd98=8d=Q5DBPY4_ZtYAOgcM1V_0+OU8UHrw@mail.gmail.com> <1478185643.7065.446.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Cong Wang <cwang@twopensource.com>,
        Vijay Pandurangan <vijayp@vijayp.ca>,
        Evan Jones <ej@evanjones.ca>, pabeni@redhat.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg65.qq.com ([103.7.28.233]:24454 "EHLO smtpbg65.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750970AbcKCPNW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 11:13:22 -0400
Received: from mail-vk0-f47.google.com (unknown [209.85.213.47])
        by esmtp4.qq.com (ESMTP) with SMTP id 0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 23:13:02 +0800 (CST)
Received: by mail-vk0-f47.google.com with SMTP id x186so42246937vkd.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 08:13:02 -0700 (PDT)
In-Reply-To: <1478185643.7065.446.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Thu, Nov 3, 2016 at 11:07 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-11-03 at 22:38 +0800, Gao Feng wrote:
>
>> Because other net devices put the statistics together.
>> Take tun/tap as example, it is a virtual device, but its all
>> statistics are percpu including dropped.
>
> Take a look at 2681128f0ced8aa4e66f221197e183cc16d244fe
> ("veth: reduce stat overhead")
>
> Feel free to fix tun/tap, not bloat veth and undo my work,
> without knowing why it was done this way.
>
> Thanks.
>
>

Thanks your detail explanations.

Best Regards
Feng
