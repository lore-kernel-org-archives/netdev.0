From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: Re: [PATCH v3 0/7] net: use platform_{get,set}_drvdata()
Date: Fri, 16 Aug 2013 10:15:40 +0800
Message-ID: <520D8B4C.8010509@huawei.com>
References: <520CD11D.8010202@huawei.com> <20130815.152359.920302339053249583.davem@davemloft.net> <20130815.153903.859166500375208182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <lizefan@huawei.com>,
	<leoli@freescale.com>, <linuxppc-dev@lists.ozlabs.org>,
	<pantelis.antoniou@gmail.com>, <vbordug@ru.mvista.com>,
	<gregkh@linuxfoundation.org>, <jg1.han@samsung.com>,
	<sergei.shtylyov@cogentembedded.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:41622 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753812Ab3HPCP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 22:15:59 -0400
In-Reply-To: <20130815.153903.859166500375208182.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/8/16 6:39, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 15 Aug 2013 15:23:59 -0700 (PDT)
>=20
>> From: Libo Chen <clbchenlibo.chen@huawei.com>
>> Date: Thu, 15 Aug 2013 21:01:17 +0800
>>
>>> Use the wrapper functions for getting and setting the driver data u=
sing
>>> platform_device instead of using dev_{get,set}_drvdata() with &pdev=
->dev,
>>> so we can directly pass a struct platform_device.
>>>
>>> changelog v3:
>>> 	remove modify about dev_set_drvdata()
>>> changelog v2:
>>> 	this version add modify record about dev_set_drvdata().
>>
>> Series applied.
>=20
> Actually, I had to revert, these patches break the build.
>=20
> drivers/net/ethernet/sun/sunhme.c: In function =A1happy_meal_pci_prob=
e=A2:
> drivers/net/ethernet/sun/sunhme.c:3114:2: error: implicit declaration=
 of function =A1platform_set_drvdata=A2 [-Werror=3Dimplicit-function-de=
claration]
> drivers/net/ethernet/sun/sunhme.c: In function =A1happy_meal_pci_remo=
ve=A2:
> drivers/net/ethernet/sun/sunhme.c:3162:9: error: implicit declaration=
 of function =A1platform_get_drvdata=A2 [-Werror=3Dimplicit-function-de=
claration]
> drivers/net/ethernet/sun/sunhme.c:3162:26: warning: initialization ma=
kes pointer from integer without a cast [enabled by default]
>=20


oh, it is my fault, I will update!
