From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/can: trying to register non-static key in can_rx_register
Date: Thu, 8 Jun 2017 17:21:39 +0200
Message-ID: <CAAeHK+yf1jFv3AxWtRu4K_0q+SY8R1R_88LBSzOayzhV0bJUzw@mail.gmail.com>
References: <CAAeHK+ywJzK4Hd=O_+j+Dw7pb=s-MgwVLJywrLAQdkwfybdu1Q@mail.gmail.com>
 <97710f24-092e-ade4-fa14-3bc812bbf42f@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
        "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <97710f24-092e-ade4-fa14-3bc812bbf42f@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 8, 2017 at 5:20 PM, Marc Kleine-Budde <mkl@pengutronix.de> wrote:
> On 06/08/2017 05:16 PM, Andrey Konovalov wrote:
>> Hi,
>>
>> I've got the following error report while fuzzing the kernel with syzkaller.
>>
>> On commit b29794ec95c6856b316c2295904208bf11ffddd9 (4.12-rc4+).
>>
>> INFO: trying to register non-static key.
>> the code is fine but needs lockdep annotation.
>> turning off the locking correctness validator.
>
> I've posted a patch for this problem earlier today:
> https://marc.info/?l=linux-can&m=149691617012069&w=2
>
> I'll send a pull request to David soon.

Great, thanks!

>
> regards,
> Marc
>
> --
> Pengutronix e.K.                  | Marc Kleine-Budde           |
> Industrial Linux Solutions        | Phone: +49-231-2826-924     |
> Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
> Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
>
