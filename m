From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next] net-gre-gro: Fix a bug that breaks the
 forwarding path
Date: Mon, 14 Jul 2014 22:05:30 +0300
Message-ID: <CAJZOPZ+wu=6t_AKoKg1KhVJ0=DhczfQ8ekDFKFLEkQv6d=cOfA@mail.gmail.com>
References: <1405262780-20232-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, linux@stwm.de,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "H.K. Jerry Chu" <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:40145 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754870AbaGNTFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 15:05:32 -0400
Received: by mail-qc0-f182.google.com with SMTP id r5so3177185qcx.13
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 12:05:30 -0700 (PDT)
In-Reply-To: <1405262780-20232-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 13, 2014 at 5:46 PM, H.K. Jerry Chu <hkchu@google.com> wrote:
>
> From: Jerry Chu <hkchu@google.com>
>
> Fixed a bug that was introduced by my GRE-GRO patch
> (bf5a755f5e9186406bbf50f4087100af5bd68e40 net-gre-gro: Add GRE
> support to the GRO stack) that breaks the forwarding path
> because various GSO related fields were not set. The bug will
> cause on the egress path either the GSO code to fail, or a
> GRE-TSO capable (NETIF_F_GSO_GRE) NICs to choke. The following
> fix has been tested for both cases.


Hi Jerry,

Anything different in this version vs. the one you posted earlier on
February or this is a plain re-post?

Or.
