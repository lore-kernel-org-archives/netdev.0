From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 00/10] korina cleanups/optimizations
Date: Sun, 15 Oct 2017 09:38:02 -0700
Message-ID: <0FA80CB3-C0DC-4B30-B638-26B5D46AE69E@gmail.com>
References: <20171015162226.606-1-roman@advem.lv>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
To: Roman Yeryomin <roman@advem.lv>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34684 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751341AbdJOQiI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 12:38:08 -0400
Received: by mail-oi0-f68.google.com with SMTP id h200so5761112oib.1
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 09:38:07 -0700 (PDT)
In-Reply-To: <20171015162226.606-1-roman@advem.lv>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On October 15, 2017 9:22:26 AM PDT, Roman Yeryomin <roman@advem=2Elv> wrote=
:
>TX optimizations have led to ~15% performance increase (35->40Mbps)
>in local tx usecase (tested with iperf v3=2E2)=2E

Could you avoid empty commit messages and write a paragraph or two for eac=
h commit that explains what and why are you changing? The changes look fine=
 but they lack any explanation=2E

>
>Roman Yeryomin (10):
>  net: korina: optimize korina_send_packet logic
>  net: korina: reorder functions
>  net: korina: introduce and use interrupt disable/enable helpers
>  net: korina: optimize tx/rx interrupt handlers
>  net: korina: remove unused korina_private members
>  net: korina: optimize tx descriptor flags processing
>  net: korina: move tx to napi context
>  net: korina: optimize tx_full condition
>  net: korina: use dma api instead of dma_cache_* functions
>  net: korina: bump version
>
>drivers/net/ethernet/korina=2Ec | 503
>+++++++++++++++++-------------------------
> 1 file changed, 204 insertions(+), 299 deletions(-)


--=20
Florian
