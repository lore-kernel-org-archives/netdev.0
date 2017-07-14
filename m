From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH 17/22] platform/x86: alienware-wmi: fix format string
 overflow warning
Date: Fri, 14 Jul 2017 22:49:44 +0300
Message-ID: <CAHp75Vfmp8Vh+f9X8tezorOOuMokQSez4r7BTPhhuorHCCBgZg@mail.gmail.com>
References: <20170714120720.906842-1-arnd@arndb.de> <20170714120720.906842-18-arnd@arndb.de>
 <CAHp75Vd2eZAj++QdGraspjpTX=VPVR6qY+iCZiHsySGvUcGVmQ@mail.gmail.com> <CAK8P3a2dRg9vepvM7mOyg14E4JCd51oJ-ZWzr+au=N+puwWayA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Darren Hart <dvhart@infradead.org>,
        Andy Shevchenko <andy@infradead.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        netdev <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        linux-scsi <linux-scsi@vger.kernel.org>,
        "x86@kernel.org" <x86@kernel.org>,
        Mario Limonciello <mario.limonciello@dell.com>,
        Arvind Yadav <arvind.yadav.cs@gmail.com>,
        Platform Driver <platform-driver-x86@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a2dRg9vepvM7mOyg14E4JCd51oJ-ZWzr+au=N+puwWayA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 14, 2017 at 10:37 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Fri, Jul 14, 2017 at 9:18 PM, Andy Shevchenko
> <andy.shevchenko@gmail.com> wrote:
>> On Fri, Jul 14, 2017 at 3:07 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>>> gcc points out a possible format string overflow for a large value of 'zone':

>> Here we need to convert
>>
>> int i;
>>
>> to
>>
>> u8 i;
>
> That was my first impulse, but then I decided not to change the
> idiomatic 'int i' for the index variable to 'u8' as that would be
> less idiomatic.
>
>> I will take it after addressing above.
>>
>> P.S. You may do this change across the file.
>
> How about changing it to 'u8 zone'?

I'm ultimately fine with that (just gentle reminder you might fix all
3 occurrences of it in that driver).

-- 
With Best Regards,
Andy Shevchenko
