From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next v2 3/9] nfp: provide infrastructure for
 offloading flower based TC filters
Date: Thu, 29 Jun 2017 16:56:44 +0300
Message-ID: <CAJ3xEMgy4Kfdu=pgVsKh21thJjEvRWptAxLXLRc5YzD68KjPGA@mail.gmail.com>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com> <1498681802-2897-4-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:35230 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752796AbdF2N4p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 09:56:45 -0400
Received: by mail-oi0-f50.google.com with SMTP id c189so66873296oia.2
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 06:56:45 -0700 (PDT)
In-Reply-To: <1498681802-2897-4-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 28, 2017 at 11:29 PM, Simon Horman
<simon.horman@netronome.com> wrote:

> +++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c

> + * nfp_flower_del_offload() - Removes a flow from hardware.
> + * @app:       Pointer to the APP handle
> + * @netdev:    netdev structure.
> + * @flow:       TC flower classifier offload structure

The copy from patchworks has some damage on this line

 * @flow: =D6=B2| =D6=B2| =D6=B2| =D6=B2| =D6=B2| =D6=B2| TC flower classif=
ier offload structure

and the same line for get stats, take a look

> + * nfp_flower_get_stats() - Populates flow stats obatain from hardware.
> + * @app:       Pointer to the APP handle
> + * @flow:       TC flower classifier offload structure <-- here too
