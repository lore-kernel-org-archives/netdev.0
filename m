From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] ipv4: synchronize bind() with RTM_NEWADDR notifications
Date: Thu, 21 Oct 2010 13:58:08 +0300
Message-ID: <4CC01CC0.7090101@iki.fi>
References: <1287655930-16879-1-git-send-email-timo.teras@iki.fi>	<1287656753.6871.46.camel@edumazet-laptop>	<4CC018E1.3000906@iki.fi> <20101021.035004.212683583.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:57586 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757154Ab0JUK6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:58:10 -0400
Received: by ewy20 with SMTP id 20so5587871ewy.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 03:58:09 -0700 (PDT)
In-Reply-To: <20101021.035004.212683583.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/2010 01:50 PM, David Miller wrote:
> From: Timo Ter=E4s <timo.teras@iki.fi>
> Date: Thu, 21 Oct 2010 13:41:37 +0300
>=20
>> Is inet_bind() called from non-userland context? If yes, then this i=
s a
>> bad idea. Otherwise I don't think it's that hot path...
>=20
> It is.

Yet, almost immediately after that there is lock_sock() which can also
sleep. How does that work then?

