From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [bug discuss] fjes driver call trace warning, "PNP0C02" used in
 fjes	seems like a bug,
Date: Thu, 9 Jun 2016 08:48:45 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A7379ED59@G01JPEXMBYT01>
References: <57515004.1080301@huawei.com>
 <EE11001F9E5DDD47B7634E2F8A612F2E1F76DB68@lhreml507-mbx>
 <E86EADE93E2D054CBCD4E708C38D364A7379C541@G01JPEXMBYT01>
 <EE11001F9E5DDD47B7634E2F8A612F2E1F7715BA@lhreml507-mbx>
 <E86EADE93E2D054CBCD4E708C38D364A7379DCD7@G01JPEXMBYT01>
 <EE11001F9E5DDD47B7634E2F8A612F2E1F7783A9@lhreml507-mbx>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Cc: Linuxarm <linuxarm@huawei.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"liudongdong (C)" <liudongdong3@huawei.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Gabriele Paoloni <gabriele.paoloni@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm02.jp.fujitsu.com ([202.219.69.169]:54360 "EHLO
	mgwkm02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751551AbcFIItC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 04:49:02 -0400
In-Reply-To: <EE11001F9E5DDD47B7634E2F8A612F2E1F7783A9@lhreml507-mbx>
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Gao,

> From a SW perspective it like an acpi driver that uses "PNP0C02"
> as driver ids to perform the driver match in the ACPI table.
> 
> From my understanding this is wrong in principle because that identifier
> must be used to reserve motherboard resources (see par 4.1.2 of the PCI
> Firmware Specifications v3.2)
> 
> Therefore such identifier it is used from
> http://lxr.free-electrons.com/source/drivers/pnp/system.c
> to reserve such resources.
> 
> Basically your driver is breaking any other device that
> needs to reserve motherboard resources through system.c
> driver.
> 
> @David Miller, what is your opinion about this?
> I think this driver should be reverted...

 I'm willing to revise my driver if it's something wrong.
 I can't reproduce this problem. Could you please show me how to reproduce problem ?

 Sincerely,
 Taku Izumi
