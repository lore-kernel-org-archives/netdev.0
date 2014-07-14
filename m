From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH net-next] net-gre-gro: Fix a bug that breaks the
 forwarding path
Date: Mon, 14 Jul 2014 15:18:14 -0700
Message-ID: <CAPshTCjTBk6pJ5YpdwTWMxoQ_vFDPhe3UjeMgM1j=KYJmQfJiA@mail.gmail.com>
References: <1405262780-20232-1-git-send-email-hkchu@google.com>
	<20140714.150513.1524175237353581279.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Wolfgang Walter <linux@stwm.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f41.google.com ([209.85.213.41]:47548 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757506AbaGNWSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 18:18:16 -0400
Received: by mail-yh0-f41.google.com with SMTP id z6so2179983yhz.28
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 15:18:15 -0700 (PDT)
In-Reply-To: <20140714.150513.1524175237353581279.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2014 at 3:05 PM, David Miller <davem@davemloft.net> wrote:
>
> From: "H.K. Jerry Chu" <hkchu@google.com>
> Date: Sun, 13 Jul 2014 07:46:20 -0700
>
> > From: Jerry Chu <hkchu@google.com>
> >
> > Fixed a bug that was introduced by my GRE-GRO patch
> > (bf5a755f5e9186406bbf50f4087100af5bd68e40 net-gre-gro: Add GRE
> > support to the GRO stack) that breaks the forwarding path
> > because various GSO related fields were not set. The bug will
> > cause on the egress path either the GSO code to fail, or a
> > GRE-TSO capable (NETIF_F_GSO_GRE) NICs to choke. The following
> > fix has been tested for both cases.
> >
> > Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
>
> As a regression fix, this should be targetted at 'net' rather than
> 'net-next' so I can queue it up for -stable too.

Ok, will submit a separate patch for 'net' soon.

Thanks,

Jerry

>
> Thanks.
