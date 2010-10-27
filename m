From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ehea: Fixing statistics
Date: Wed, 27 Oct 2010 20:53:30 +0200
Message-ID: <1288205610.2658.2.camel@edumazet-laptop>
References: <20101027.113940.242117937.davem@davemloft.net>
	 <1288205114-852-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:64663 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752793Ab0J0Sxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 14:53:37 -0400
Received: by ewy7 with SMTP id 7so967570ewy.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 11:53:36 -0700 (PDT)
In-Reply-To: <1288205114-852-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 27 octobre 2010 =C3=A0 14:45 -0400, Breno Leitao a =C3=A9cr=
it :
> (Applied over Eric's "ehea: fix use after free" patch)
>=20
> Currently ehea stats are broken. The bytes counters are got from
> the hardware, while the packets counters are got from the device
> driver. Also, the device driver counters are resetted during the
> the down process, and the hardware aren't, causing some weird
> numbers.
>=20
> This patch just consolidates the packets and bytes on the device
> driver.
>=20
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>



