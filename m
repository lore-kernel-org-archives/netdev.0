From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ipv4/route.c: respect prefsrc for local routes
Date: Tue, 4 Jan 2011 16:07:08 +0800
Message-ID: <AANLkTimDms0FTmXWf9WSpcxwZXVVSXQj44jZ2Ag8Osuk@mail.gmail.com>
References: <1294122260-13245-1-git-send-email-jsing@google.com>
 <1294125880.2711.34.camel@edumazet-laptop> <1294126407.2711.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joel Sing <jsing@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36105 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751910Ab1ADIH3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 03:07:29 -0500
Received: by fxm20 with SMTP id 20so13857564fxm.19
        for <netdev@vger.kernel.org>; Tue, 04 Jan 2011 00:07:28 -0800 (PST)
In-Reply-To: <1294126407.2711.39.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 4, 2011 at 3:33 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mardi 04 janvier 2011 =E0 08:24 +0100, Eric Dumazet a =E9crit :
>
>> Please use FIB_RES_PREFSRC(res)
>>
>
> Hmm no, this is not applicable, but this could be shorter :
>
> fl.fl4_src =3D res.fi->fib_prefsrc ? : fl.fl4_dst;
>
>

I think Joe may object the use of "? :"

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
