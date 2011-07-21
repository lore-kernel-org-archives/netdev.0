From: Fernando Gont <fernando@gont.com.ar>
Subject: Re: [PATCH net-next-2.6] ipv6: make fragment identifications less
 predictable
Date: Wed, 20 Jul 2011 22:32:18 -0300
Message-ID: <4E2781A2.8020905@gont.com.ar>
References: <4E24BE94.7010301@gont.com.ar>	 <1311082696.2375.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	 <1311089463.2375.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	 <1311108423.3113.24.camel@edumazet-laptop>	 <1311150327.2338.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1311157648.2338.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, security@kernel.org,
	Eugene Teo <eugeneteo@kernel.sg>,
	netdev <netdev@vger.kernel.org>, Matt Mackall <mpm@selenic.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:42808 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425Ab1GUHpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 03:45:24 -0400
Received: by ywe9 with SMTP id 9so531984ywe.19
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2011 00:45:23 -0700 (PDT)
In-Reply-To: <1311157648.2338.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/20/2011 07:27 AM, Eric Dumazet wrote:
> Le mercredi 20 juillet 2011 =C3=A0 10:25 +0200, Eric Dumazet a =C3=A9=
crit :
>=20
>> Please hold on, I'll make a different patch series to ease stable te=
ams
>> job. It appears inetpeer & ipv6 are really not an option for old
>> kernels.
>>
>> Common patch for all kernels :
>> 1) Fix the problem without inetpeer help
>> ---=20
>> Patches for next kernels
>> 2) random split as suggested by Matt Mackal
>> 3) Use inetpeer cache to scale identification generation
>=20
> Here is the first patch, applicable on net-2.6 / linux-2.6 and stable
> kernels.

Does it make sense to go in this direction rather than simply randomize
the IPv6 Fragment Identification?

Keep in mind that IPv6 routers don't perform fragmentation, that that
the IPv6 identification is 32-bits long.

Thanks,
--=20
=46ernando Gont
e-mail: fernando@gont.com.ar || fgont@acm.org
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1



