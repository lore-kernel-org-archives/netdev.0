From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v4 05/10] drivers: base: Add
 device_find_in_class_name()
Date: Tue, 17 Jan 2017 15:43:25 -0800
Message-ID: <b8cc0d2f-f544-0e06-32bd-47e6b9be5393@gmail.com>
References: <20170117232152.1661-1-f.fainelli@gmail.com>
 <20170117232152.1661-6-f.fainelli@gmail.com>
 <CAHp75VfE8t+_2Yu1NYMErKopnCNwFakO6pyDRmqAU-ZsGuyvmg@mail.gmail.com>
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
In-Reply-To: <CAHp75VfE8t+_2Yu1NYMErKopnCNwFakO6pyDRmqAU-ZsGuyvmg@mail.gmail.com>
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

On 01/17/2017 03:34 PM, Andy Shevchenko wrote:
> On Wed, Jan 18, 2017 at 1:21 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> Add a helper function to lookup a device reference given a class name.
>> This is a preliminary patch to remove adhoc code from net/dsa/dsa.c and
>> make it more generic.
> 
> 
>> +static int device_class_name_match(struct device *dev, void *class)
> 
> And why not const char *class?

This was raised back in v2, and the same response applies:

https://www.mail-archive.com/netdev@vger.kernel.org/msg147559.html

Changing the signature of a callback is out of the scope of this patch
series.
-- 
Florian
