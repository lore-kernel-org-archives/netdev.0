From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH net-next v4 05/10] drivers: base: Add device_find_in_class_name()
Date: Wed, 18 Jan 2017 02:07:24 +0200
Message-ID: <CAHp75VeqLb2hDgj2jfWzQgw4wa31gckSw=jZS0UhUAnZgNA14Q@mail.gmail.com>
References: <20170117232152.1661-1-f.fainelli@gmail.com> <20170117232152.1661-6-f.fainelli@gmail.com>
 <CAHp75VfE8t+_2Yu1NYMErKopnCNwFakO6pyDRmqAU-ZsGuyvmg@mail.gmail.com>
 <b8cc0d2f-f544-0e06-32bd-47e6b9be5393@gmail.com> <CAHp75Ve9xn6wDxFwnkPDyY8yVwVysK3-pUsoxv3GfVbbEVZoBg@mail.gmail.com>
 <e3132d31-f94f-8794-1121-0fe25be2f61b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "moderated list:ARM/Marvell Dove/MV78xx0/Orion SOC support"
        <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e3132d31-f94f-8794-1121-0fe25be2f61b@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 18, 2017 at 2:04 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 01/17/2017 04:00 PM, Andy Shevchenko wrote:
>> On Wed, Jan 18, 2017 at 1:43 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>> On 01/17/2017 03:34 PM, Andy Shevchenko wrote:
>>>> On Wed, Jan 18, 2017 at 1:21 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:

>> But why not to use void *class_name to be consistent with callback and
>> device_find_child()?
>
> The top-level function: device_find_in_class_name() should have a
> stronger typing of its argument even if it internally uses
> device_find_child() and a callback that takes a void * argument, that's
> how I see it.

Fair enough.

>> Btw,
>> return get_device(parent);
>
> Not sure I follow what that means here?

Missed remark. Instead of

get_device(parent);
return parent;

you can use

return get_device(parent);

-- 
With Best Regards,
Andy Shevchenko
