From: zeal <zealcook@gmail.com>
Subject: Re: [PATCH 1/2 v2] KS8695: fix ks8695_rx_irq() bug.
Date: Tue, 17 Nov 2009 12:28:33 +0800
Message-ID: <efc9214f0911162028te62eca0h90f11b9b1e7a5d6e@mail.gmail.com>
References: <4b016886.1d255e0a.16f1.ffff866a@mx.google.com>
	 <1258043088.1931.13.camel@myhost>
	 <efc9214f0911160718o4c7cd0ecv2e86b8d5ad7691ae@mail.gmail.com>
	 <1258045910.1931.16.camel@myhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, ben@simtec.co.uk, davem@davemloft.net
To: "Figo.zhang" <figo1802@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:63405 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754139AbZKQE22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 23:28:28 -0500
Received: by ywh40 with SMTP id 40so3787411ywh.33
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 20:28:33 -0800 (PST)
In-Reply-To: <1258045910.1931.16.camel@myhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 1:11 AM, Figo.zhang <figo1802@gmail.com> wrote:
> On Mon, 2009-11-16 at 23:18 +0800, zeal wrote:
>> On Fri, Nov 13, 2009 at 12:24 AM, Figo.zhang <figo1802@gmail.com> wrote:
>> > On Mon, 2009-11-16 at 22:58 +0800, zeal wrote:
>> >> From: zeal <zealcook@gmail.com>
>> >>
>> >> Sorry for the previously patches. THEY'RE NOT RIGHT. It's my mistake.
>> >> Please forgive my noise.
>> >> Please review the following patches and ignore the last (v1).
>> >>
>> >> ks8695 rx irq is edge-level. Before arriving at irq handler, the
>> >> corresponding status bit has been clear(irq's ack).
>> >> So we should not check it after that.
>> >
>> > see <KS8695X Integrated Multi-Port Gateway Solution Register
>> > Description> Version 1.00
>> >
>> > Interrupt Status Register(INTST Offset 0xE208)
>> >
>> > it has said: This edge-triggered interrupt status is cleared by writting
>> > 1 , so we should write 1 to clear status bit manually.
>> >
>> Yeah, but irq_chip's ack has done that.
>> Please check arch/arm/mach-ks8695/irq.c ks8695_irq_edge_chip->ack()
>
> yes, you are right, but you have better add this description at commit
> log.

'the corresponding status bit has been clear(irq's ack)' is not enough?

[snip]

-- 
Thanks & Regards

zeal
