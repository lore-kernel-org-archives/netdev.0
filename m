From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH v2 net-next 0/7] net: speedup netns create/delete time
Date: Thu, 19 Oct 2017 14:48:37 +0300
Message-ID: <be222d71-0b61-9256-6d39-cbb9d762cd22@mellanox.com>
References: <20170919232709.14690-1-edumazet@google.com>
 <8edb310a-562d-bff1-0482-64314833e722@mellanox.com>
 <CANn89i+LE6He_E3VHwUTpLAVW+uUGo+FPs_zg1bs4P3CVcCL6Q@mail.gmail.com>
 <266d30e7-5164-48e8-b802-56bb93558823@mellanox.com>
 <CANn89iJ4io_gX-V8A4hE04cH=czGZYs8WGBOpaiBpWMMHOgVVw@mail.gmail.com>
 <33E69A03-6594-423A-86E6-02029046BE7D@gmail.com>
 <CANn89iKq86_FRaL7Y3Ekhf_JD8NY2s8PWibGN+WdmJL1TsPXJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tariq Toukan <tariqt@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Majd Dibbiny <majd@mellanox.com>,
        Yonatan Cohen <yonatanc@mellanox.com>,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Eric Dumazet <edumazet@google.com>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0071.outbound.protection.outlook.com ([104.47.1.71]:35616
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751680AbdJSLtL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 07:49:11 -0400
In-Reply-To: <CANn89iKq86_FRaL7Y3Ekhf_JD8NY2s8PWibGN+WdmJL1TsPXJA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 26/09/2017 6:30 PM, Eric Dumazet wrote:
> On Tue, Sep 26, 2017 at 8:22 AM, Dmitry Torokhov
> <dmitry.torokhov@gmail.com> wrote:
> 
>> It is in Greg's tree where all kobject patches should go through as far as I know.
> 
> Yes, I will fix this, adding a second memmove()
> 
Hi Eric,

I just wanted to check if this is solved already, as I don't want to 
keep an unnecessary revert patch in our internal branches.
According to my check bug still exists.

Thanks,
Tariq
