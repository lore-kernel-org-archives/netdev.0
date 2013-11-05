From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] can: add Renesas R-Car CAN driver
Date: Wed, 06 Nov 2013 01:59:26 +0300
Message-ID: <5279784E.1010205@cogentembedded.com>
References: <201310250303.00695.sergei.shtylyov@cogentembedded.com> <526AC65B.5020203@grandegger.com> <52742A0F.7040707@cogentembedded.com> <5276A63E.3070505@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: Wolfgang Grandegger <wg@grandegger.com>, netdev@vger.kernel.org,
	mkl@pengutronix.de, linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:44849 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755669Ab3KEV7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 16:59:31 -0500
Received: by mail-lb0-f170.google.com with SMTP id u14so7096446lbd.15
        for <netdev@vger.kernel.org>; Tue, 05 Nov 2013 13:59:30 -0800 (PST)
In-Reply-To: <5276A63E.3070505@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/03/2013 10:38 PM, Wolfgang Grandegger wrote:

>>>> Add support for the CAN controller found in Renesas R-Car SoCs.

>>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

>> [...]

>>>> Index: linux-can-next/drivers/net/can/rcar_can.c
>>>> ===================================================================
>>>> --- /dev/null
>>>> +++ linux-can-next/drivers/net/can/rcar_can.c
>>>> @@ -0,0 +1,920 @@
>> [...]

>>>> +            rcar_can_writeb(priv, RCAR_CAN_ECSR, (u8)~ECSR_ADEF);

>>> Please avoid casts here and below.

>>     These casts help avoid compiler warnings.

> Well instead of using casts the declaration of ECSR_ADEF and otheres
> should be fixed. I think the problem is that BIT is declared as shown below:

>   #define BIT(nr)                 (1UL << (nr))

> Using BIT seems not appropriate here.

    Well, I thought it was designed to replace explicit (1 << (nr)) #define's. 
Hopefully those are good for you then...

> Wolfgang,

WBR, Sergei
