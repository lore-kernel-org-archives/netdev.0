From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: [PATCH] smsc-ircc2: Fix section mismatch derived from
 smsc_ircc_pnp_driver variable
Date: Mon, 3 Jan 2011 22:16:34 +0100
Message-ID: <AANLkTimB3CsS5EVK-KiU9=MfAV9+Gu0=fL4770WKpA0i@mail.gmail.com>
References: <1294021724-30337-1-git-send-email-sedat.dilek@gmail.com>
	<20110103.115319.245401044.davem@davemloft.net>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110103.115319.245401044.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 3, 2011 at 8:53 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: Sedat Dilek <sedat.dilek@googlemail.com>
> Date: Mon, =C2=A03 Jan 2011 03:28:44 +0100
>
>>>From my build.log:
>>
>> drivers/net/irda/smsc-ircc2.o(.data+0x18): Section mismatch in refer=
ence from the variable smsc_ircc_pnp_driver to the function .init.text:=
smsc_ircc_pnp_probe()
>> The variable smsc_ircc_pnp_driver references
>> the function __init smsc_ircc_pnp_probe()
>> If the reference is valid then annotate the
>> variable with __init* or __refdata (see linux/init.h) or name the va=
riable:
>> *_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,
>>
>> This patch fixes the warning.
>>
>> Tested with linux-next (next-20101231)
>>
>> Signed-off-by: Sedat Dilek <sedat.dilek@gmail.com>
>
> Just like your other patch, this fix is not correct.
>
> Mark smsc_ircc_pbp_probe() as __devinit instead of __init to fix
> this bug.
>

I have sent a new fixed version.

- Sedat -
