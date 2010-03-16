From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] route: Fix caught BUG_ON during
 rt_secret_rebuild_oneshot()
Date: Tue, 16 Mar 2010 19:08:42 +0100
Message-ID: <1268762922.2932.3.camel@edumazet-laptop>
References: <201003161407.51925.vgusev@openvz.org>
	 <20100316143437.GA8225@hmsreliant.think-freely.org>
	 <201003161827.08595.vgusev@openvz.org>
	 <20100316173543.GA13529@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vitaliy Gusev <vgusev@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f211.google.com ([209.85.218.211]:60527 "EHLO
	mail-bw0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479Ab0CPSIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 14:08:46 -0400
Received: by bwz3 with SMTP id 3so266628bwz.29
        for <netdev@vger.kernel.org>; Tue, 16 Mar 2010 11:08:44 -0700 (PDT)
In-Reply-To: <20100316173543.GA13529@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 16 mars 2010 =C3=A0 13:35 -0400, Neil Horman a =C3=A9crit :
> >=20
> Dave, Eric, Herbert, what are your opinions on this?  Is the statisti=
cal analysis code
> mature enough at this point to warrant the removal of the rebuild tim=
er, or
> should we still keep it as a fallback mechanism?
> Neil

I believe most heavy duty users dont use newest kernels yet.

(I had to make some changes last month because Pawe=C5=82 Staszewski ha=
d
problems to get a working route cache)

We should wait a bit (one year or two) before removing this timer.

Thanks


