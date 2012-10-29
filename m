From: Javier Domingo <javierdo1@gmail.com>
Subject: Re: Information about napi_struct and net_device
Date: Mon, 29 Oct 2012 12:49:51 +0100
Message-ID: <CALZVapmSRsSYFea_PE0G9UWq-XgMaWLqnp6r9-Y8RGxVtf4Zpw@mail.gmail.com>
References: <CALZVap=ybdWdK22LHsfSRu+TVCJnvL95KeChtCdX8DE-C=1gAg@mail.gmail.com>
 <1351357421.30380.328.camel@edumazet-glaptop> <20121027182207.GA12858@electric-eye.fr.zoreil.com>
 <1351378943.30380.332.camel@edumazet-glaptop> <CALZVapkYdSRB9j+KnXdC7wT9iXqrZvXBcAK=Pk9uFoWwLgDNYg@mail.gmail.com>
 <20121028231300.GA27196@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:60745 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758652Ab2J2LuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 07:50:12 -0400
Received: by mail-vc0-f174.google.com with SMTP id fk26so5106030vcb.19
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2012 04:50:11 -0700 (PDT)
In-Reply-To: <20121028231300.GA27196@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Francois,

I have been reading the code you recommended, and I think I must have
misexplained myself. I am not developing a driver, I am updating a
patch that we use at our research group, in which we modify linux to
make our custom packet processing, getting all the packets from the
NICs into a custom queue for processing.

It will obviously not going to be integrated in the linux kernel,
because its way to work is just useful to us, thought when we have
something that works, we have planned to distribute it.

I work with net_device, because I mainly use its fields, but I provide
functions to enable/disable capturing from a specific net_device. Now,
as napi_struct has appeared, I can't no longer use the
netif_rx_disable/enable functions, but I still need to know how to get
the already created napi_struct from my net_device pointers.

I think I have been looking in a too low level,

Regards,

Javier Domingo


2012/10/29 Francois Romieu <romieu@fr.zoreil.com>:
> Javier Domingo <javierdo1@gmail.com> :
> [...]
>>               inside of the net_device structure, I know I can take
>> the net_device pointer as documented in [3], but how may  I obtain the
>> napi_struct from the netdevice? or I am doing it the wrong way?
>
> You are doing it the wrong way. The napi_struct you need is not embedded
> here. See
>
> $ less +/napi drivers/net/ethernet/realtek/8139cp.c
>
> (first match in struct cp_private).
>
> You should really read one of the existing drivers.
>
> --
> Ueimor
