From: Salam Noureddine <noureddine@arista.com>
Subject: Re: [OOPS] In __netif_receive_skb_core
Date: Tue, 12 Jan 2016 10:15:17 -0800
Message-ID: <CAO7SqHBM2QtYHPP9Yp=aUwOqR_tDPH4LOSey-+=oPbsD_huFLw@mail.gmail.com>
References: <568EA671.7000502@gmail.com>
	<56929985.3020502@gmail.com>
	<1452457610.16445.13.camel@edumazet-glaptop2.roam.corp.google.com>
	<5694188F.80907@gmail.com>
	<CAO7SqHA9dNUDG+pYJoQvipE_ErM4Bgo0_o9er_OLxZLDgNVJ8Q@mail.gmail.com>
	<56944DFA.4050002@gmail.com>
	<1452560786.1223.6.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAO7SqHC+fTCyNd8ukSH4tJ1qPvAYzMGSfhrzXmMn0NLve6NTQA@mail.gmail.com>
	<1452565288.1223.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<1452565515.1223.11.camel@edumazet-glaptop2.roam.corp.google.com>
	<5694A840.8030900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?Q?Pali_Roh=C3=A1r?= <pali.rohar@gmail.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Sebastian Reichel <sre@kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35115 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762204AbcALSPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 13:15:18 -0500
Received: by mail-wm0-f49.google.com with SMTP id f206so263792869wmf.0
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 10:15:17 -0800 (PST)
In-Reply-To: <5694A840.8030900@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 11:16 PM, Ivaylo Dimitrov
<ivo.g.dimitrov.75@gmail.com> wrote:

>>> On Mon, 2016-01-11 at 17:19 -0800, Salam Noureddine wrote:
>>>>
>>>> It must be that skb->dev was changed to NULL inside of
>>>> __netif_receive_skb_core, otherwise we would have crashed much
>>>> earlier. Also, orig_dev is saved at the beginning. Possibly a device
>>>> is layered on top of the original device.
>
>
> Exactly (skb->dev was changed to NULL ...). Do you think it makes sense to
> put printks in various places in __netif_receive_skb_core to see after which
> function call skb->dev turns into NULL?
>

No need anymore since Eric found the culprit in phonet_rcv.
Thanks for your help debugging this!

Salam
