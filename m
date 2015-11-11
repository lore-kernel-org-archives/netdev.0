From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Wed, 11 Nov 2015 02:36:43 +0200
Message-ID: <CAHp75VfeABnw6AipxWf2w-EDPUCA2xzFuQhaPrq=b12gb3Y0KQ@mail.gmail.com>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
	<CAHp75Vch3vJEqYsCRUoctEmF0EoFx+0y7ZO+LjmdpQKAoikiOA@mail.gmail.com>
	<yw1xr3jxpjoy.fsf@unicorn.mansr.com>
	<CAHp75VfsswYAvkkkHuaEvkTAgZhoGZQ1oQ_R9BwZgyZ3xRVDeg@mail.gmail.com>
	<yw1xmvulpi6r.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, slash.tmp@free.fr
To: =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1xmvulpi6r.fsf@unicorn.mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 11, 2015 at 1:07 AM, M=C3=A5ns Rullg=C3=A5rd <mans@mansr.co=
m> wrote:
> Andy Shevchenko <andy.shevchenko@gmail.com> writes:

>>>>> +       nb8800_writel(priv, NB8800_TX_DESC_ADDR, txb->dma_desc);
>>>>> +       wmb();          /* ensure desc addr is written before sta=
rting DMA */
>>>>
>>>> Hm=E2=80=A6 Have I missed corresponding rmb() ? If it's about MMIO=
, perhaps mmiowb() ?
>>>
>>> Possibly.
>>
>> Standalone wmb() doesn't make sense.
>
> It does if you need to enforce ordering between normal and I/O memory=
=2E
> In fact, since the descriptor is filled in using normal memory access=
es,
> my understanding is that mmiowb() would be insufficient here.  The
> comment could be improved, however.

Can you then explain what exactly you are assured against in all cases
where you are using wmb()s? It seems I don't recognize this part in
some excerpts.


--=20
With Best Regards,
Andy Shevchenko
