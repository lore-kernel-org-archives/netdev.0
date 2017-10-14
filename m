From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH v3 0/6] staging: Introduce DPAA2 Ethernet Switch driver
Date: Sat, 14 Oct 2017 13:09:28 +0200
Message-ID: <CACRpkdazUB_XLv2jYnSiGe9CeVTgjOQ4HfPDL8+CNUVxs-LcLA@mail.gmail.com>
References: <1507194974-12050-1-git-send-email-razvan.stefanescu@nxp.com>
 <CACRpkdYJCzu9Ph8XMYXt=SSAX+ZaiwXqUGgWX5UvTabmMxmBNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
 Arnd Bergmann <arnd@arndb.de>, Greg KH <gregkh@linuxfoundation.org>,
 alexandru.marginean@nxp.com,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Alexander Graf <agraf@suse.de>, stuyoder@gmail.com, bogdan.purcareata@nxp.com,
 laurentiu.tudor@nxp.com
To: Razvan Stefanescu <razvan.stefanescu@nxp.com>,
 OpenWrt Development List <openwrt-devel@lists.openwrt.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CACRpkdYJCzu9Ph8XMYXt=SSAX+ZaiwXqUGgWX5UvTabmMxmBNQ@mail.gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Top posting and resending since netdev@vger.kernel.org
is the right mail address for this. Mea culpa.

Linus Walleij

On Sat, Oct 14, 2017 at 11:35 AM, Linus Walleij
<linus.walleij@linaro.org> wrote:
> On Thu, Oct 5, 2017 at 11:16 AM, Razvan Stefanescu
> <razvan.stefanescu@nxp.com> wrote:
>
>> This patchset introduces the Ethernet Switch Driver for Freescale/NXP SoCs
>> with DPAA2 (DataPath Acceleration Architecture v2). The driver manages
>> switch objects discovered on the fsl-mc bus. A description of the driver
>> can be found in the associated README file.
>>
>> The patchset consists of:
>> * A set of libraries containing APIs for configuring and controlling
>>   Management Complex (MC) switch objects
>> * The DPAA2 Ethernet Switch driver
>> * Patch adding ethtool support
>
> So it appears that ethernet switches is a class of device that need their own
> subsystem in Linux, before this driver can move out of staging.
>
> I ran into the problem in OpenWRT that has these out-of-tree patches for
> off-chip ethernet switches, conveniently placed under net/phy:
> https://github.com/openwrt/openwrt/tree/master/target/linux/generic/files/drivers/net/phy
>
> These are some 12 different ethernet switches. It is used in more or
> less every home router out there.
>
> It's not really working to have all of this out-of-tree, there must have been
> discussions about the requirements for a proper ethernet switch subsystem.
>
> I'm not a good net developers, just a grumpy user having to deal with all
> of this out-of-tree code that's not helpful with changing interfaces like
> device tree and so on.
>
> Can you people who worked on this over the years pit in with your
> requirements for an ethernet switch subsystem so we can house these
> drivers in a proper way?
>
> What we need AFAICT:
>
> - Consensus on userspace ABI
> - Consensus on ethtool extenstions
> - Consensus on where in drivers/net this goes
>
> You can kick me for not knowing what I'm talking about and how complex the
> problem is now.
>
> Yours,
> Linus Walleij
