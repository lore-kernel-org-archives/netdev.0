From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next-2.6] e1000e: Use the instance of net_device_stats
	from net_device.
Date: Wed, 7 Oct 2009 16:36:03 -0700
Message-ID: <9929d2390910071636p7516c998l4c3c729f6a7f16ce@mail.gmail.com>
References: <20091007124416.GA30096@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ajit Khaparde <ajitk@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.216.179]:33244 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753494AbZJGXgk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 19:36:40 -0400
Received: by pxi9 with SMTP id 9so5267755pxi.4
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2009 16:36:03 -0700 (PDT)
In-Reply-To: <20091007124416.GA30096@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 7, 2009 at 05:44, Ajit Khaparde <ajitkhaparde@gmail.com> wr=
ote:
> Since net_device has an instance of net_device_stats,
> we can remove the instance of this from the private adapter structure=
=2E
>
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
> ---
> =C2=A0drivers/net/e1000e/e1000.h =C2=A0 | =C2=A0 =C2=A01 -
> =C2=A0drivers/net/e1000e/ethtool.c | =C2=A0 18 +++++++++-------
> =C2=A0drivers/net/e1000e/netdev.c =C2=A0| =C2=A0 43 +++++++++++++++++=
+++---------------------
> =C2=A03 files changed, 31 insertions(+), 31 deletions(-)
>

I have added this patch to my tree for testing purposes, thanks.

--=20
Cheers,
Jeff
