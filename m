From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next-2.6] ixgb: Use the instance of net_device_stats
	from net_device.
Date: Wed, 7 Oct 2009 16:38:16 -0700
Message-ID: <9929d2390910071638j7f2c7a13u54deb5e7d98f9bdf@mail.gmail.com>
References: <20091007124648.GA30172@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ajit Khaparde <ajitk@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f177.google.com ([209.85.222.177]:49587 "EHLO
	mail-pz0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753498AbZJGXix convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 19:38:53 -0400
Received: by pzk7 with SMTP id 7so505200pzk.33
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2009 16:38:16 -0700 (PDT)
In-Reply-To: <20091007124648.GA30172@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 7, 2009 at 05:46, Ajit Khaparde <ajitkhaparde@gmail.com> wr=
ote:
> Since net_device has an instance of net_device_stats,
> we can remove the instance of this from the private adapter structure=
=2E
>
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
> ---
> =C2=A0drivers/net/ixgb/ixgb.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=
=A01 -
> =C2=A0drivers/net/ixgb/ixgb_ethtool.c | =C2=A0 44 +++++++++++++++++++=
+------------------
> =C2=A0drivers/net/ixgb/ixgb_main.c =C2=A0 =C2=A0| =C2=A0 44 +++++++++=
+++++++++--------------------
> =C2=A03 files changed, 44 insertions(+), 45 deletions(-)
>

I have added this patch to my tree for testing purposes, thanks.

--=20
Cheers,
Jeff
