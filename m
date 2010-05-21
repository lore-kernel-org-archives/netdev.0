From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: bnx2x + SFP+ DA/2.6.33.3: Got bad status 0x0 when reading from
 SFP+ EEPROM -> SFP+ module is not initialized
Date: Fri, 21 May 2010 15:19:16 +0200
Message-ID: <4BF68854.5060409@ans.pl>
References: <4BF56CA6.8080306@ans.pl> <1274377770.28702.4.camel@lb-tlvb-eilong.il.broadcom.com> <4BF57ADF.1060203@ans.pl> <1274381113.28702.6.camel@lb-tlvb-eilong.il.broadcom.com> <4BF59058.6050205@ans.pl> <4BF59ABB.9070600@hp.com> <4BF5A19E.5010003@ans.pl> <1274446713.11082.3.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>, Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:42073 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774Ab0EUNT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 09:19:29 -0400
In-Reply-To: <1274446713.11082.3.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-05-21 14:58, Eilon Greenstein wrote:
> On Thu, 2010-05-20 at 13:54 -0700, Krzysztof Ol=C4=99dzki wrote:
>> On 2010-05-20 22:25, Rick Jones wrote:
>>> Some simple/simplistic thoughts/questions...
>>>
>>> Has the DAC been used successfully prior to this?
>>
>> Yes. It was successfully used to connect two HP switches, before I
>> received SFP+ SR modules, that allowed me to put the switches into
>> distanced rooms.
>
> Krzysztof,
>
> I would like to check in what speed the I2C is running at, and while =
we
> are there, to make sure it is at low speed (100KHz and not 400KHz). C=
an
> you please add this patch and let me know what you see:

Sure.

>
> diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c

<CUT>

[bnx2x_8727_read_sfp_module_eeprom:2774(eth4)]I2C 2W speed 0x0, bit 8 0
[bnx2x_8727_read_sfp_module_eeprom:2774(eth5)]I2C 2W speed 0x0, bit 8 0

> Since we are already off for the weekend, I couldn't find a machine w=
ith
> this kind of board to test it for myself. On top of that, I don't hav=
e
> this type of DAC cable, so I need your help in this debug process.

No problem. There is no need to ask for a help a person who depends on=20
your support. ;) I would like to solve it as soon as possible so I'm=20
willing to test everything you send me. ;)

best regards,

			Krzysztof Ol=C4=99dzki

