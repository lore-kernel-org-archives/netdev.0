From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v2 3/9] nfp: provide infrastructure for
 offloading flower based TC filters
Date: Thu, 29 Jun 2017 16:31:49 +0200
Message-ID: <20170629143147.GA4149@vergenet.net>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
 <1498681802-2897-4-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMgy4Kfdu=pgVsKh21thJjEvRWptAxLXLRc5YzD68KjPGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37490 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753157AbdF2Oby (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 10:31:54 -0400
Received: by mail-wm0-f52.google.com with SMTP id i127so16860785wma.0
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 07:31:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMgy4Kfdu=pgVsKh21thJjEvRWptAxLXLRc5YzD68KjPGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 29, 2017 at 04:56:44PM +0300, Or Gerlitz wrote:
> On Wed, Jun 28, 2017 at 11:29 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> 
> > +++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
> 
> > + * nfp_flower_del_offload() - Removes a flow from hardware.
> > + * @app:       Pointer to the APP handle
> > + * @netdev:    netdev structure.
> > + * @flow:       TC flower classifier offload structure
> 
> The copy from patchworks has some damage on this line
> 
>  * @flow: ֲ| ֲ| ֲ| ֲ| ֲ| ֲ| TC flower classifier offload structure
> 
> and the same line for get stats, take a look

Thanks, I will fix that whitespace damage.

> 
> > + * nfp_flower_get_stats() - Populates flow stats obatain from hardware.
> > + * @app:       Pointer to the APP handle
> > + * @flow:       TC flower classifier offload structure <-- here too
