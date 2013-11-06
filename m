From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v2] can: add Renesas R-Car CAN driver
Date: Wed, 06 Nov 2013 09:08:20 +0100
Message-ID: <1a1ef40a4f59b71daf33f958d8cc5b2e@grandegger.com>
References: <201310250303.00695.sergei.shtylyov@cogentembedded.com>
 <526AC65B.5020203@grandegger.com> <52742A0F.7040707@cogentembedded.com>
 <5276A63E.3070505@grandegger.com> <5279784E.1010205@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <mkl@pengutronix.de>,
	<linux-can@vger.kernel.org>, <linux-sh@vger.kernel.org>,
	<vksavl@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5279784E.1010205@cogentembedded.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 06 Nov 2013 01:59:26 +0300, Sergei Shtylyov

<sergei.shtylyov@cogentembedded.com> wrote:

> Hello.

> 

> On 11/03/2013 10:38 PM, Wolfgang Grandegger wrote:

> 

>>>>> Add support for the CAN controller found in Renesas R-Car SoCs.

> 

>>>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> 

>>> [...]

> 

>>>>> Index: linux-can-next/drivers/net/can/rcar_can.c

>>>>> ===================================================================

>>>>> --- /dev/null

>>>>> +++ linux-can-next/drivers/net/can/rcar_can.c

>>>>> @@ -0,0 +1,920 @@

>>> [...]

> 

>>>>> +            rcar_can_writeb(priv, RCAR_CAN_ECSR, (u8)~ECSR_ADEF);

> 

>>>> Please avoid casts here and below.

> 

>>>     These casts help avoid compiler warnings.

> 

>> Well instead of using casts the declaration of ECSR_ADEF and otheres

>> should be fixed. I think the problem is that BIT is declared as shown

>> below:

> 

>>   #define BIT(nr)                 (1UL << (nr))

> 

>> Using BIT seems not appropriate here.

> 

>     Well, I thought it was designed to replace explicit (1 << (nr))

>     #define's.



Me too.



> Hopefully those are good for you then...



Yes, of course.



Wolfgang.


