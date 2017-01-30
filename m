From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 0/4] net: dsa: bcm_sf2: CFP support
Date: Sun, 29 Jan 2017 22:46:01 -0800
Message-ID: <F1B63CEA-29D4-4BC7-9476-9D489E4A4FB9@gmail.com>
References: <20170129031325.21911-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: davem@davemloft.net, cphealy@gmail.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f195.google.com ([74.125.82.195]:33307 "EHLO
        mail-ot0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752128AbdA3Gwo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 01:52:44 -0500
Received: by mail-ot0-f195.google.com with SMTP id f9so37460769otd.0
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 22:52:44 -0800 (PST)
In-Reply-To: <20170129031325.21911-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On January 28, 2017 7:13:21 PM PST, Florian Fainelli <f=2Efainelli@gmail=2E=
com> wrote:
>Hi all,
>
>This patch series adds support for the Broadcom Compact Field Processor
>(CFP)
>which is a classification and matching engine built into most Broadcom
>switches=2E
>
>We support that using ethtool::rxnfc because it allows all known uses
>cases from
>the users I support to work, and more importantly, it allows the
>selection of a
>target rule index, which is later used by e=2Eg: offloading hardware,
>this is an
>essential feature that I could not find being supported with cls_* for
>instance=2E

David, this needs to be rebase against net-next/master after Vivien's chan=
ges=2E Will post an update tomorrow=2E Thanks!

--=20
Florian
