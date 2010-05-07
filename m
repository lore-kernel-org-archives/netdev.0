From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Fri, 07 May 2010 19:21:33 +0200
Message-ID: <1273252893.2261.84.camel@edumazet-laptop>
References: <1273085598.2367.233.camel@edumazet-laptop>
	 <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
	 <1273147586.2357.63.camel@edumazet-laptop>
	 <20100506.220443.135536330.davem@davemloft.net>
	 <1273210329.2222.42.camel@edumazet-laptop>
	 <20100507101451.1b4286b7@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bhaskie@gmail.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:41948 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752591Ab0EGRVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 13:21:38 -0400
Received: by bwz19 with SMTP id 19so713428bwz.21
        for <netdev@vger.kernel.org>; Fri, 07 May 2010 10:21:37 -0700 (PDT)
In-Reply-To: <20100507101451.1b4286b7@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 07 mai 2010 =C3=A0 10:14 -0700, Stephen Hemminger a =C3=A9c=
rit :

> Forget the per cpu data; the pool should just be scrapped.
>=20
> The only reason the pool exists is that the crypto hash state which
> should just be moved into the md5_info (88 bytes).  The pseudo
> header can just be generated on the stack before passing to the crypt=
o
> code.


Sure, but I'm afraid there is no generic API do do that (if we want to
reuse crypto/md5.c code)



