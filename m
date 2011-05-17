From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: small RPS cache for fragments?
Date: Wed, 18 May 2011 07:59:05 +0800
Message-ID: <BANLkTimmvKn2e5Yrkd5TtktyxTWCRxqinw@mail.gmail.com>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
 <BANLkTikyH=q_6uOvFh3_Z_xwPST3zVijZw@mail.gmail.com> <20110517.164929.1737248436066795381.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:52608 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932286Ab1EQX70 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 19:59:26 -0400
Received: by bwz15 with SMTP id 15so942851bwz.19
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 16:59:25 -0700 (PDT)
In-Reply-To: <20110517.164929.1737248436066795381.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 18, 2011 at 4:49 AM, David Miller <davem@davemloft.net> wro=
te:
>
> Actually, I think it won't work. =A0Even Linux emits fragments last t=
o
> first, so we won't see the UDP header until the last packet where it'=
s
> no longer useful.
>

No. Linux emits fragments first to last now. You should check the
current code. :)

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
