From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next-2.6] igb: Use the instance of net_device_stats
	from net_device.
Date: Wed, 7 Oct 2009 16:32:58 -0700
Message-ID: <9929d2390910071632o12cd3d76n79e01c4e085fec22@mail.gmail.com>
References: <20091007124245.GA30070@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ajit Khaparde <ajitk@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.216.179]:60157 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756538AbZJGXde convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 19:33:34 -0400
Received: by pxi9 with SMTP id 9so5266025pxi.4
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2009 16:32:58 -0700 (PDT)
In-Reply-To: <20091007124245.GA30070@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 7, 2009 at 05:42, Ajit Khaparde <ajitkhaparde@gmail.com> wr=
ote:
> Since net_device has an instance of net_device_stats,
> we can remove the instance of this from the adapter structure.
>
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
> ---
> =C2=A0drivers/net/igb/igb.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A0=
1 -
> =C2=A0drivers/net/igb/igb_ethtool.c | =C2=A0 20 +++++++++++---------
> =C2=A0drivers/net/igb/igb_main.c =C2=A0 =C2=A0| =C2=A0 39 +++++++++++=
++++++++--------------------
> =C2=A03 files changed, 30 insertions(+), 30 deletions(-)
>

I have added this patch to my tree for testing purposes, thanks.

--=20
Cheers,
Jeff
