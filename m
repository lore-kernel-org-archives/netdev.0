From: Denis Kirjanov <kirjanov@gmail.com>
Subject: Re: [PATCH 1/6] r8169: check dma mapping failures
Date: Fri, 15 Oct 2010 18:23:55 +0400
Message-ID: <AANLkTimwwhBJdoXcvSt-wdTGv5biHJj094s0TutFM66N@mail.gmail.com>
References: <1287144922-3297-1-git-send-email-sgruszka@redhat.com>
	<20101015134158.GA4417@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stanislaw Gruszka <sgruszka@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:49921 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756168Ab0JOOYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 10:24:05 -0400
Received: by vws2 with SMTP id 2so386881vws.19
        for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 07:24:05 -0700 (PDT)
In-Reply-To: <20101015134158.GA4417@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Right, we should pass TX_BUSY to upper layers only when the device hw
queue is full

On Fri, Oct 15, 2010 at 5:41 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Stanislaw Gruszka <sgruszka@redhat.com> :
>> Check possible dma mapping errors and do clean up if it happens,
>> when sending frames stop the tx queue.
>
> Almost ok: NETDEV_TX_BUSY can not be used like that. Afaik the DMA
> failure path in the driver really wants a NETDEV_TX_OK (and a device
> stats update, though missing in tg3 ?).
>
> Actually the former NETDEV_TX_BUSY condition mostly checks for a bug.
>
> --
> Ueimor
>



-- 
Regards,
Denis
