From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: macb: zynq: why is SG disabled?
Date: Thu, 2 Jul 2015 09:48:34 +0200
Message-ID: <5594ECD2.7090701@atmel.com>
References: <559403E3.3050900@certsign.ro> <55941D80.2090904@atmel.com> <03CA77BA8AF6F1469AEDFBDA1322A7B7495B9EE3@XAP-PVEXMBX02.xlnx.xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>,
	"Cyrille Pitchen" <cyrille.pitchen@atmel.com>,
	Nicolae Rosia <nicolae.rosia@certsign.ro>,
	Michal Simek <michals@xilinx.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:15266 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbbGBHtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 03:49:46 -0400
In-Reply-To: <03CA77BA8AF6F1469AEDFBDA1322A7B7495B9EE3@XAP-PVEXMBX02.xlnx.xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/07/2015 04:33, Punnaiah Choudary Kalluri a =E9crit :
> Hi Nicolae and Cyrille,
>=20
>    SG feature was not tested for Zynq using macb driver but tested it=
 using the
>  emacps Driver in Xilinx tree (this driver is deprecated recently)
>=20
> We will test and enable this feature in driver for Zynq.

Ok, fine: we will be glad to merge patches that would enable this
feature on Zynq.

Bye,


>> -----Original Message-----
>> From: Cyrille Pitchen [mailto:cyrille.pitchen@atmel.com]
>> Sent: Wednesday, July 01, 2015 10:34 PM
>> To: Nicolae Rosia; Michal Simek; Punnaiah Choudary Kalluri;
>> netdev@vger.kernel.org; Nicolas Ferre; linux-arm-kernel@lists.infrad=
ead.org
>> Subject: Re: macb: zynq: why is SG disabled?
>>
>> Le 01/07/2015 17:14, Nicolae Rosia a =E9crit :
>>> Hello,
>>>
>>> After reading the GEM part of Zynq7000 Technical Reference Manual [=
0], I
>> think that SG should be supported.
>>> Is there a reason why SG is disabled in macb for Zynq?
>>>
>>> Best regards,
>>> Nicolae Rosia
>>
>> Hi Nicolae,
>>
>> when the scatter-gather patch was introduced, the feature was enable=
d only
>> on tested boards to avoid regressions on other boards.
>> So SG is enabled on sama5d4x and sama5d2x SoCs. SG is disabled on pu=
rpose
>> on sama5d3x.
>>
>> For Zynq, I think the feature is still disabled just because it has =
never been
>> tested.
>>
>> Best regards,
>>
>> Cyrille
>=20


--=20
Nicolas Ferre
