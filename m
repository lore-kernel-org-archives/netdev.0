From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] Passing sk_buff metadata information to user space in
 TUNTAP driver.
Date: Mon, 19 Aug 2013 13:49:08 -0700
Message-ID: <CAHo-Ooy4S8tzOBqZQJEEvkAqMJdYCf2XTYZpkFHk=PZJP7z-Ng@mail.gmail.com>
References: <1376944177-20031-1-git-send-email-vytautas.valancius@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Valas Valancius <valas@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux NetDev <netdev@vger.kernel.org>
To: Valas Valancius <vytautas.valancius@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f172.google.com ([209.85.220.172]:33265 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996Ab3HSUtK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 16:49:10 -0400
Received: by mail-vc0-f172.google.com with SMTP id m17so3474039vca.31
        for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 13:49:09 -0700 (PDT)
In-Reply-To: <1376944177-20031-1-git-send-email-vytautas.valancius@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Maciej =C5=BBenczykowski <maze@google.com>

I've already reviewed / commented on previous versions of this patch
and am hoping for comments from a wider audience.

I'm hoping this relatively generic and easily extensible way of
exposing additional per-packet metadata to userspace catches on.
Something similar would also be useful for tcpdump (ie. raw packet sock=
ets).

- Maciej
