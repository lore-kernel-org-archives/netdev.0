From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: [PATCH] ksz884x: Fix section mismatch derived from
 pci_device_driver variable
Date: Mon, 3 Jan 2011 22:07:48 +0100
Message-ID: <AANLkTina2xL94To2WrU_Y=O175iTO5mTaf8pwC0UGfRp@mail.gmail.com>
References: <1294020104-17124-1-git-send-email-sedat.dilek@gmail.com>
	<20110103.115248.179942629.davem@davemloft.net>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110103.115248.179942629.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 3, 2011 at 8:52 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: Sedat Dilek <sedat.dilek@googlemail.com>
> Date: Mon, =C2=A03 Jan 2011 03:01:44 +0100
>
>> WARNING: drivers/net/ksz884x.o(.data+0x18): Section mismatch in refe=
rence from the variable pci_device_driver to the function .init.text:pc=
idev_init()
>> The variable pci_device_driver references
>> the function __init pcidev_init()
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
> pcidev_init() should be marked __devinit instead of __init to fix thi=
s
> bug.
>

I have sent a new fixed version.

- Sedat -
