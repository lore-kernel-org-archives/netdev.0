From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET/r8169: Rework suspend and resume
Date: Mon, 13 Apr 2009 16:20:42 -0700 (PDT)
Message-ID: <20090413.162042.79456870.davem@davemloft.net>
References: <200904052040.04752.rjw@sisk.pl>
	<20090405223318.5a494e4e@neptune.home>
	<200904052359.31629.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bonbons@linux-vserver.org, romieu@fr.zoreil.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-pm@lists.linux-foundation.org
To: rjw@sisk.pl
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754367AbZDMXVM@vger.kernel.org>
In-Reply-To: <200904052359.31629.rjw@sisk.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Sun, 5 Apr 2009 23:59:31 +0200

> On Sunday 05 April 2009, Bruno Pr=E9mont wrote:
>> On Sun, 05 April 2009 "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
>> > From: Rafael J. Wysocki <rjw@sisk.pl>
>> >=20
>> > The recent changes of the PCI PM core allow us to simplify the
>> > suspend and resume handling in a number of device drivers, since t=
hey
>> > don't need to carry out the general PCI PM operations, such as
>> > changing the power state of the device, during suspend and resume =
any
>> > more.
>> >=20
>> > Simplify the suspend and resume callbacks of r8169 using the
>> > observation that the PCI PM core can take care of some operations
>> > carried out by the driver.
>> >=20
>> > Additionally, make the shutdown callback of r8169 only put the dev=
ice
>> > into a low power state if the system is going to be powered off
>> > (kexec is known to have problems with network adapters that are pu=
t
>> > into low power states on shutdown).
>> >=20
>> > This patch has been tested on MSI Wind U100.
>>=20
>> Tested against 2.6.29.1 on my Commell LE-365 and suspend (S3) + WoL
>> still works as expected.
>>=20
>> 02:08.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd.
>>                      RTL-8169 Gigabit Ethernet [10ec:8169] (rev 10)
>=20
> Thanks for testing!

I've applied this patch to net-next-2.6, thanks everyone.
