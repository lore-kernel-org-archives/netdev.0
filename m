From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: Re: [PATCH] net: wan: Use dma_pool_zalloc
Date: Thu, 15 Dec 2016 10:41:30 +0530
Message-ID: <CAFqt6zaHJ_YP-inLm8_XRDrX8FtcU86NqYG=+DRn9-Y3zR4cyg@mail.gmail.com>
References: <20161203091447.GA5231@jordon-HP-15-Notebook-PC>
 <m3wpf9l0fc.fsf@t19.piap.pl> <CAFqt6zZoEfE8Us+vx_VuFyqK-zth9ac=aZXo2MKD-4RUBqm5GQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Rameshwar Sahu <sahu.rameshwar73@gmail.com>
To: =?UTF-8?Q?Krzysztof_Ha=C5=82asa?= <khalasa@piap.pl>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:32812 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753745AbcLOF2H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 00:28:07 -0500
Received: by mail-io0-f195.google.com with SMTP id p13so7335331ioi.0
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 21:28:07 -0800 (PST)
In-Reply-To: <CAFqt6zZoEfE8Us+vx_VuFyqK-zth9ac=aZXo2MKD-4RUBqm5GQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 12, 2016 at 10:12 AM, Souptick Joarder <jrdr.linux@gmail.com> w=
rote:
> On Fri, Dec 9, 2016 at 6:33 PM, Krzysztof Ha=C5=82asa <khalasa@piap.pl> w=
rote:
>> Souptick Joarder <jrdr.linux@gmail.com> writes:
>>
>>> We should use dma_pool_zalloc instead of dma_pool_alloc/memset
>>>
>>> Signed-off-by: Souptick joarder <jrdr.linux@gmail.com>
>>> ---
>>>  drivers/net/wan/ixp4xx_hss.c | 5 ++---
>>>  1 file changed, 2 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.=
c
>>> index e7bbdb7..aaabf31 100644
>>> --- a/drivers/net/wan/ixp4xx_hss.c
>>> +++ b/drivers/net/wan/ixp4xx_hss.c
>>> @@ -976,10 +976,9 @@ static int init_hdlc_queues(struct port *port)
>>>                       return -ENOMEM;
>>>       }
>>>
>>> -     if (!(port->desc_tab =3D dma_pool_alloc(dma_pool, GFP_KERNEL,
>>> -                                           &port->desc_tab_phys)))
>>> +     if (!(port->desc_tab =3D dma_pool_zalloc(dma_pool, GFP_KERNEL,
>>> +                                            &port->desc_tab_phys)))
>>>               return -ENOMEM;
>>> -     memset(port->desc_tab, 0, POOL_ALLOC_SIZE);
>>>       memset(port->rx_buff_tab, 0, sizeof(port->rx_buff_tab)); /* table=
s */
>>>       memset(port->tx_buff_tab, 0, sizeof(port->tx_buff_tab));
>>
>> This look fine, feel free to send it to the netdev mailing list for
>> inclusion.
>
> Including netdev mailing list based as requested.
>
>>
>> Acked-by: Krzysztof Halasa <khalasa@piap.pl>
>> --
>> Krzysztof Halasa
>>
>> Industrial Research Institute for Automation and Measurements PIAP
>> Al. Jerozolimskie 202, 02-486 Warsaw, Poland

Any comment on this patch ?
