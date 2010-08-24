From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] TCP_FAILFAST: a new socket option to timeout/abort a
 connection quicker
Date: Tue, 24 Aug 2010 08:44:22 +0200
Message-ID: <1282632262.2378.1681.camel@edumazet-laptop>
References: <1282630819-23104-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, davem@davemloft.net,
	netdev@vger.kernel.org
To: "H.K. Jerry Chu" <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34692 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980Ab0HXGo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 02:44:28 -0400
Received: by wyb35 with SMTP id 35so75584wyb.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 23:44:27 -0700 (PDT)
In-Reply-To: <1282630819-23104-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 23 ao=C3=BBt 2010 =C3=A0 23:20 -0700, H.K. Jerry Chu a =C3=A9c=
rit :
> From: Jerry Chu <hkchu@google.com>
>=20
> This is a TCP level socket option that takes an unsigned int to speci=
fy
> how long in ms TCP should resend a lost data packet before giving up
> and returning ETIMEDOUT. The normal TCP retry/abort timeout limit sti=
ll
> applies. In other words this option is only meant for those applicati=
ons
> that need to "fail faster" than the default TCP timeout. The latter
> may take upto 20 minutes in a normal WAN environment.
>=20
> The option is disabled (by default) when set to 0. Also it does not
> apply during the connection establishment phase.
>=20
> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>

TCP_FAILFAST might be misleading. It reads as a boolean option, while
its an option to cap the timeout, with a time unit, instead of the usua=
l
"number of retransmits".

Its also funny you dont ask for a default value, given by a sysctl
tunable ;)



