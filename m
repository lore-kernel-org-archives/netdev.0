From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods
Date: Tue, 19 Jul 2011 22:41:47 +0200
Message-ID: <1311108107.3113.22.camel@edumazet-laptop>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
	 <1311105738.3113.11.camel@edumazet-laptop>
	 <20110719202922.GA2352@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37130 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092Ab1GSUlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 16:41:52 -0400
Received: by wwe5 with SMTP id 5so4552627wwe.1
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 13:41:51 -0700 (PDT)
In-Reply-To: <20110719202922.GA2352@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 juillet 2011 =C3=A0 22:29 +0200, Jiri Pirko a =C3=A9crit :

> You are right, but it may not cause panic, right? In case this patch
> would cause significant performance regression, how about to just for=
bid
> pktgen to run on soft-netdevs ?
>=20

Please do

Note : a sysadmin has other ways to make a machine panic or reboot or
halt...



