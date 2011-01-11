From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH v4 05/10] net/fec: add dual fec support for mx28
Date: Tue, 11 Jan 2011 23:25:41 +1000
Message-ID: <4D2C5A55.7050502@snapgear.com>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>	<1294297998-26930-6-git-send-email-shawn.guo@freescale.com>	<20110111102717.GG26617@pengutronix.de>	<4D2C4BEC.1030003@snapgear.com> <20110111130749.GQ24920@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <baruch@tkos.co.il>, <B32542@freescale.com>,
	<netdev@vger.kernel.org>, Sascha Hauer <s.hauer@pengutronix.de>,
	<jamie@shareable.org>, <w.sang@pengutronix.de>,
	<r64343@freescale.com>, <linux-arm-kernel@lists.infradead.org>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>, <jamie@jamieiles.com>,
	<davem@davemloft.net>, Shawn Guo <shawn.guo@freescale.com>,
	<lw@karo-electronics.de>
To: =?ISO-8859-1?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sncsmrelay2.nai.com ([67.97.80.206]:42218 "EHLO
	sncsmrelay2.nai.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754009Ab1AKN2w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 08:28:52 -0500
In-Reply-To: <20110111130749.GQ24920@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Uwe,

On 11/01/11 23:07, Uwe Kleine-K=F6nig wrote:
> Hi Greg,
>
> On Tue, Jan 11, 2011 at 10:24:12PM +1000, Greg Ungerer wrote:
>> On 11/01/11 20:27, Sascha Hauer wrote:
>>> On Thu, Jan 06, 2011 at 03:13:13PM +0800, Shawn Guo wrote:
>>> This option is used nowhere and should be removed. Certainly it doe=
s not
>>> have the effect of enabling the second ethernet controller.
>>
>> It does for a ColdFire platform...
>>
>> grep -r CONFIG_FEC2 *
>>
>> arch/m68knommu/configs/m5275evb_defconfig:CONFIG_FEC2=3Dy
>> arch/m68knommu/platform/527x/config.c:#ifdef CONFIG_FEC2
>> arch/m68knommu/platform/527x/config.c:#ifdef CONFIG_FEC2
> IMHO Sascha's comment[1] applies here, too.

I am not arguing that it doesn't :-)

Simply that removing that config option and doing nothing
else would not be the right thing to do.

Regards
Greg


> And someone might want to do what he suggested soon or the patch
> removing CONFIG_FEC2[2] needs to be commented accordingly.
>
> Best regards
> Uwe
>
> [1] http://thread.gmane.org/gmane.linux.network/182929/focus=3D183378
> [2] http://mid.gmane.org/1294747672-4433-1-git-send-email-shawn.guo@f=
reescale.com
>


--=20
-----------------------------------------------------------------------=
-
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.co=
m
SnapGear Group, McAfee                      PHONE:       +61 7 3435 288=
8
8 Gardner Close,                            FAX:         +61 7 3891 363=
0
Milton, QLD, 4064, Australia                WEB: http://www.SnapGear.co=
m
