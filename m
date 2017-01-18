From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v4 05/10] drivers: base: Add
 device_find_in_class_name()
Date: Tue, 17 Jan 2017 16:13:11 -0800
Message-ID: <dbb8a715-0e34-24a6-803e-dad4b13d14af@gmail.com>
References: <20170117232152.1661-1-f.fainelli@gmail.com>
 <20170117232152.1661-6-f.fainelli@gmail.com>
 <CAHp75VfE8t+_2Yu1NYMErKopnCNwFakO6pyDRmqAU-ZsGuyvmg@mail.gmail.com>
 <b8cc0d2f-f544-0e06-32bd-47e6b9be5393@gmail.com>
 <CAHp75Ve9xn6wDxFwnkPDyY8yVwVysK3-pUsoxv3GfVbbEVZoBg@mail.gmail.com>
 <e3132d31-f94f-8794-1121-0fe25be2f61b@gmail.com>
 <CAHp75VeqLb2hDgj2jfWzQgw4wa31gckSw=jZS0UhUAnZgNA14Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
 netdev <netdev@vger.kernel.org>, Russell King <linux@armlinux.org.uk>,
 open list <linux-kernel@vger.kernel.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 "David S. Miller" <davem@davemloft.net>,
 "moderated list:ARM/Marvell Dove/MV78xx0/Orion SOC support"
 <linux-arm-kernel@lists.infradead.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAHp75VeqLb2hDgj2jfWzQgw4wa31gckSw=jZS0UhUAnZgNA14Q@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 01/17/2017 04:07 PM, Andy Shevchenko wrote:
> On Wed, Jan 18, 2017 at 2:04 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> On 01/17/2017 04:00 PM, Andy Shevchenko wrote:
>>> On Wed, Jan 18, 2017 at 1:43 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>>> On 01/17/2017 03:34 PM, Andy Shevchenko wrote:
>>>>> On Wed, Jan 18, 2017 at 1:21 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> 
>>> But why not to use void *class_name to be consistent with callback and
>>> device_find_child()?
>>
>> The top-level function: device_find_in_class_name() should have a
>> stronger typing of its argument even if it internally uses
>> device_find_child() and a callback that takes a void * argument, that's
>> how I see it.
> 
> Fair enough.
> 
>>> Btw,
>>> return get_device(parent);
>>
>> Not sure I follow what that means here?
> 
> Missed remark. Instead of
> 
> get_device(parent);
> return parent;
> 
> you can use
> 
> return get_device(parent);

Seems reasonable, if I have to respin a v5, will add that, thanks!
-- 
Florian
