From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ehea: Remove sleep at .ndo_get_stats
Date: Mon, 26 Sep 2011 22:28:55 +0200
Message-ID: <1317068935.2796.12.camel@edumazet-laptop>
References: <1317066179.2796.9.camel@edumazet-laptop>
	 <1317067863-11706-1-git-send-email-brenohl@br.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: brenohl@br.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64696 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753075Ab1IZU3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 16:29:02 -0400
Received: by wwf22 with SMTP id 22so7281119wwf.1
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 13:29:01 -0700 (PDT)
In-Reply-To: <1317067863-11706-1-git-send-email-brenohl@br.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 26 septembre 2011 =C3=A0 17:11 -0300, brenohl@br.ibm.com a =C3=
=A9crit :
> Currently ehea ndo_get_stats can sleep in two places, in a hcall
> and in a GFP_KERNEL alloc, which is not correct.
> This patch creates a delayed workqueue that grabs the information eac=
h 1
> sec from the hardware, and place it into the device structure, so tha=
t,
> .ndo_get_stats quickly returns the device structure statistics block.
>=20
> Signed-off-by: Breno Leitao <brenohl@br.ibm.com>
> ---

Seems good, thanks

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
