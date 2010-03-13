From: Steven Harms <thisdyingdream@gmail.com>
Subject: Re: [PATCH] NET: tg3: fix brace, switch, and comma spacing coding
	style in tg3.c This is a patch to the tg3.c file that aligns switch and case
	statements, else statements following braces, and inserts a space after
	commas listed in the coding style g
Date: Sat, 13 Mar 2010 14:52:26 -0500
Message-ID: <b6bf7b051003131152t38c8b1e1m33e8844468b9e46a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sjharms@gmail.com, mcarlson@broadcom.com, mchan@broadcom.com,
	benli@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sharms@ubuntu.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

Would you like me to submit the patch adding only the spaces after
commas and leave the rest of the defines as is, or discard the changes
all together?

On Sat, Mar 13, 2010 at 2:49 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Steven Harms <sjharms@gmail.com>
> Date: Sat, 13 Mar 2010 14:39:11 -0500
>
>> -#define tw32_mailbox(reg, val) =A0 =A0 =A0 tp->write32_mbox(tp, reg=
, val)
>> -#define tw32_mailbox_f(reg, val) =A0 =A0 tw32_mailbox_flush(tp, (re=
g), (val))
>> -#define tw32_rx_mbox(reg, val) =A0 =A0 =A0 tp->write32_rx_mbox(tp, =
reg, val)
>> -#define tw32_tx_mbox(reg, val) =A0 =A0 =A0 tp->write32_tx_mbox(tp, =
reg, val)
>> -#define tr32_mailbox(reg) =A0 =A0tp->read32_mbox(tp, reg)
>> +#define tw32_mailbox(reg, val) =A0 =A0 =A0 (tp->write32_mbox(tp, re=
g, val))
>
> Please keep this kind of code masterbation to yourself.
> This is not the style we want for this driver.
>



--=20
GPG Key ID: C92EF367 / 1428 FE8E 1E07 DDA8 EFD7 195F DCCD F5B3 C92E F36=
7

WWW: http://www.sharms.org/blog
