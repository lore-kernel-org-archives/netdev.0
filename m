From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFT PATCH] net: remove legacy ethtool ops
Date: Sat, 7 May 2011 04:58:07 -0700
Message-ID: <BANLkTikHS0=XaVb4tutWAJTYcMLgYPzTGA@mail.gmail.com>
References: <20110507114802.A0C841389B@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	e1000-devel@lists.sourceforge.net
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33309 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754361Ab1EGL6I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 07:58:08 -0400
Received: by fxm17 with SMTP id 17so2828685fxm.19
        for <netdev@vger.kernel.org>; Sat, 07 May 2011 04:58:07 -0700 (PDT)
In-Reply-To: <20110507114802.A0C841389B@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/7 Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>:
> As all drivers are converted, we may now remove discrete offload sett=
ing
> callback handling.
>
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>
> Note: This needs to wait for Intel guys to finish conversion of their
> LAN drivers.
>
> =C2=A0include/linux/ethtool.h =C2=A0 | =C2=A0 52 ------
> =C2=A0include/linux/netdevice.h | =C2=A0 16 --
> =C2=A0net/8021q/vlan_dev.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 +-
> =C2=A0net/core/dev.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0=
 13 +-
> =C2=A0net/core/ethtool.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0399 +++--=
----------------------------------------
> =C2=A05 files changed, 28 insertions(+), 454 deletions(-)
>

I do apologize for the delay, we did find several problems with the
original set of patches you submitted during review and testing.
Currently we have fixed up the e1000e, yet there is still work to be
done on the other drivers.  I will make every effort to make sure that
we complete the work over the next week.

--=20
Cheers,
Jeff
