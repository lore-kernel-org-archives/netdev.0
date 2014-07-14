From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH net-next] net-gre-gro: Fix a bug that breaks the
 forwarding path
Date: Mon, 14 Jul 2014 12:16:27 -0700
Message-ID: <CAPshTCjiw8vFK9Y4APwsX5kWnKDByLuOn+1MJa4C08FOevZKQQ@mail.gmail.com>
References: <1405262780-20232-1-git-send-email-hkchu@google.com>
	<CAJZOPZ+wu=6t_AKoKg1KhVJ0=DhczfQ8ekDFKFLEkQv6d=cOfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Wolfgang Walter <linux@stwm.de>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:51463 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756925AbaGNTQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 15:16:28 -0400
Received: by mail-yk0-f178.google.com with SMTP id 142so1126316ykq.23
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 12:16:27 -0700 (PDT)
In-Reply-To: <CAJZOPZ+wu=6t_AKoKg1KhVJ0=DhczfQ8ekDFKFLEkQv6d=cOfA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Or,

On Mon, Jul 14, 2014 at 12:05 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
>
> On Sun, Jul 13, 2014 at 5:46 PM, H.K. Jerry Chu <hkchu@google.com> wrote:
> >
> > From: Jerry Chu <hkchu@google.com>
> >
> > Fixed a bug that was introduced by my GRE-GRO patch
> > (bf5a755f5e9186406bbf50f4087100af5bd68e40 net-gre-gro: Add GRE
> > support to the GRO stack) that breaks the forwarding path
> > because various GSO related fields were not set. The bug will
> > cause on the egress path either the GSO code to fail, or a
> > GRE-TSO capable (NETIF_F_GSO_GRE) NICs to choke. The following
> > fix has been tested for both cases.
>
>
> Hi Jerry,
>
> Anything different in this version vs. the one you posted earlier on
> February or this is a plain re-post?

I simply moved the patch against the latest net-next and resolved some small
conflict so yes it's pretty much the same. Also I don't see the subsequent
discussion on skb->encapsulation affects the validity of this patch so
i'm resubmitting
it. Also the patch has been confirmed to address the problem Wolfgang reported
last week. Feel free to test against the configuration (VXLAN?) you
had some question about earlier.

Thanks,

Jerry

>
>
> Or.
