From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: Re: [PATCH] net: wan: Use dma_pool_zalloc
Date: Mon, 12 Dec 2016 10:12:38 +0530
Message-ID: <CAFqt6zZoEfE8Us+vx_VuFyqK-zth9ac=aZXo2MKD-4RUBqm5GQ@mail.gmail.com>
References: <20161203091447.GA5231@jordon-HP-15-Notebook-PC> <m3wpf9l0fc.fsf@t19.piap.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Rameshwar Sahu <sahu.rameshwar73@gmail.com>
To: =?UTF-8?Q?Krzysztof_Ha=C5=82asa?= <khalasa@piap.pl>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34003 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753833AbcLLEmk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2016 23:42:40 -0500
Received: by mail-io0-f195.google.com with SMTP id y124so19358130iof.1
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2016 20:42:39 -0800 (PST)
In-Reply-To: <m3wpf9l0fc.fsf@t19.piap.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 9, 2016 at 6:33 PM, Krzysztof Ha=C5=82asa <khalasa@piap.pl> wro=
te:
> Souptick Joarder <jrdr.linux@gmail.com> writes:
>
>> We should use dma_pool_zalloc instead of dma_pool_alloc/memset
>>
>> Signed-off-by: Souptick joarder <jrdr.linux@gmail.com>
>> ---
>>  drivers/net/wan/ixp4xx_hss.c | 5 ++---
>>  1 file changed, 2 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.c
>> index e7bbdb7..aaabf31 100644
>> --- a/drivers/net/wan/ixp4xx_hss.c
>> +++ b/drivers/net/wan/ixp4xx_hss.c
>> @@ -976,10 +976,9 @@ static int init_hdlc_queues(struct port *port)
>>                       return -ENOMEM;
>>       }
>>
>> -     if (!(port->desc_tab =3D dma_pool_alloc(dma_pool, GFP_KERNEL,
>> -                                           &port->desc_tab_phys)))
>> +     if (!(port->desc_tab =3D dma_pool_zalloc(dma_pool, GFP_KERNEL,
>> +                                            &port->desc_tab_phys)))
>>               return -ENOMEM;
>> -     memset(port->desc_tab, 0, POOL_ALLOC_SIZE);
>>       memset(port->rx_buff_tab, 0, sizeof(port->rx_buff_tab)); /* tables=
 */
>>       memset(port->tx_buff_tab, 0, sizeof(port->tx_buff_tab));
>
> This look fine, feel free to send it to the netdev mailing list for
> inclusion.

Including netdev mailing list based as requested.

>
> Acked-by: Krzysztof Halasa <khalasa@piap.pl>
> --
> Krzysztof Halasa
>
> Industrial Research Institute for Automation and Measurements PIAP
> Al. Jerozolimskie 202, 02-486 Warsaw, Poland
