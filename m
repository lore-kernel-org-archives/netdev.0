From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: [PATCH] depca: Fix section mismatch derived from depca_isa_driver variable
Date: Mon, 3 Jan 2011 22:23:03 +0100
Message-ID: <AANLkTikZh4qZgDjJPbX=iSKKfU+mcNE87nd4vO_p1euV@mail.gmail.com>
References: <1294021987-30385-1-git-send-email-sedat.dilek@gmail.com>
	<20110103.115336.70200097.davem@davemloft.net>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110103.115336.70200097.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 3, 2011 at 8:53 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: Sedat Dilek <sedat.dilek@googlemail.com>
> Date: Mon, =C2=A03 Jan 2011 03:33:07 +0100
>
>>>From my build.log:
>>
>> WARNING: drivers/net/depca.o(.data+0x0): Section mismatch in referen=
ce from the variable depca_isa_driver to the function .init.text:depca_=
isa_probe()
>> The variable depca_isa_driver references
>> the function __init depca_isa_probe()
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
> Again, mark depca_isa_probe() as __devinit to fix this bug.
>

Thanks for the pointer, I have sent a new fixed version.

- Sedat -
