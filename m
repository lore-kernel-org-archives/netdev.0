From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Wed, 14 Dec 2011 20:22:39 +0200
Message-ID: <4EE8E96F.5050707@iki.fi>
References: <4EE8C6A8.3060308@iki.fi> <20111214.125010.82857701285437834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:59728 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756962Ab1LNSWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 13:22:45 -0500
Received: by lagp5 with SMTP id p5so584338lag.19
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2011 10:22:43 -0800 (PST)
In-Reply-To: <20111214.125010.82857701285437834.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/14/2011 07:50 PM, David Miller wrote:
> From: Timo Ter=E4s <timo.teras@iki.fi>
> Date: Wed, 14 Dec 2011 17:54:16 +0200
>=20
>> So something is does not get updated here. This used to work though.
>> The current production boxes where I know this work is 2.6.38.8.
>=20
> We store the PMTU externally in inetpeer entries, Eric Dumazet
> fixed recently but that fix hasn't been submitted to -stable
> yet.
>=20
> I'd recommend using 3.1.x if possible if you can't wait.

I'll test 3.1.x though to verify that this is fixed.

I'd prefer 3.0.x for now as we have some other patchsets on production
kernels that are not yet available for 3.1.x. And this does sound like
-stable material anyway. If it's just a few commits, I could backport
and cherry-pick them. Could some point me the commits in question?

Thanks,
 Timo
