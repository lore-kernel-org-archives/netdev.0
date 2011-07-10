From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH] natsemi: silence dma-debug warnings
Date: Sun, 10 Jul 2011 10:20:39 +0900 (JST)
Message-ID: <20110710.102039.1305564732068163396.fujita.tomonori@lab.ntt.co.jp>
References: <20110704142153O.fujita.tomonori@lab.ntt.co.jp>
	<20110703.223448.458910310802724750.davem@davemloft.net>
	<CAJfuBxxKYNvaw5t4jWMP4+hYcw42SkwLiiahVdeezpfh6AsLBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, thockin@hockin.org, netdev@vger.kernel.org
To: jim.cromie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:55514 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051Ab1GJCGN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2011 22:06:13 -0400
In-Reply-To: <CAJfuBxxKYNvaw5t4jWMP4+hYcw42SkwLiiahVdeezpfh6AsLBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 9 Jul 2011 14:11:25 -0600
Jim Cromie <jim.cromie@gmail.com> wrote:

> On Sun, Jul 3, 2011 at 11:34 PM, David Miller <davem@davemloft.net> w=
rote:
>> From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
>> Date: Mon, 4 Jul 2011 14:30:19 +0900
>>
>>> This silences dma-debug warnings:
>>>
>>> https://lkml.org/lkml/2011/6/30/341
>> =A0...
>>> Reported-by: Jim Cromie <jim.cromie@gmail.com>
>>> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
>>> Tested-by: Jim Cromie <jim.cromie@gmail.com>
>>
>> Applied, thanks!
>>
>=20
> I have since seen a similar warning on shutdown,
> heres a patch for it.

Oops, I noticed this too but I forgot to send a patch.

The patch looks good to me.


> theres one other callsite, but I havent seen the warning from it,
> will try to tickle it at some point.

Which pci_unmap_single are you talking about?
