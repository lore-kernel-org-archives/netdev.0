From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [PATCH] ipv6: Fix ipv6_getsockopt for IPV6_2292PKTOPTIONS
Date: Fri, 19 Aug 2011 14:23:22 +0300
Message-ID: <CAEnQRZBDXdgKqQJGymB13g_F73wY764cgvSL40tB=1GDmMto4g@mail.gmail.com>
References: <1313747758-10063-1-git-send-email-dbaluta@ixiacom.com>
	<20110819.031957.1143398061283788162.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	netdev@vger.kernel.org, sdumitru@ixiacom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:39943 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000Ab1HSLXX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 07:23:23 -0400
Received: by qwk3 with SMTP id 3so1972003qwk.19
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 04:23:23 -0700 (PDT)
In-Reply-To: <20110819.031957.1143398061283788162.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2011 at 1:19 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Daniel Baluta <dbaluta@ixiacom.com>
> Date: Fri, 19 Aug 2011 12:55:58 +0300
>
>> IPV6_2292PKTOPTIONS is broken for 32-bit applications running
>> in COMPAT mode on 64-bit kernels.
>>
>> The same problem was fixed for IPv4 with the patch:
>> ipv4: Fix ip_getsockopt for IP_PKTOPTIONS,
>> commit dd23198e58cd35259dd09e8892bbdb90f1d57748
>>
>> Signed-off-by: Sorin Dumitru <sdumitru@ixiacom.com>
>> Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
>
> Applied, but:
>
>> - =A0 =A0 err =3D do_ipv6_getsockopt(sk, level, optname, optval, opt=
len);
>> + =A0 =A0 err =3D do_ipv6_getsockopt(sk, level, optname, optval, opt=
len,
>
> This adds trailing whitespace, which GIT catches and warns about,
> please be mindful of this in the future.
>
> I took care of it and fixed it up this time.

Thanks David. I will pay more attention to this next time.

Daniel.
