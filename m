From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: RST: binding oif to iif for tcp v4
Date: Fri, 03 Feb 2012 22:31:59 +0100
Message-ID: <1328304719.2480.5.camel@edumazet-laptop>
References: <1328300212-18836-1-git-send-email-shawn.lu@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, xiaoclu@gmail.com
To: Shawn Lu <shawn.lu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:44187 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753032Ab2BCVcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 16:32:03 -0500
Received: by werb13 with SMTP id b13so3035570wer.19
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2012 13:32:02 -0800 (PST)
In-Reply-To: <1328300212-18836-1-git-send-email-shawn.lu@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 f=C3=A9vrier 2012 =C3=A0 12:16 -0800, Shawn Lu a =C3=A9c=
rit :
> Binding RST packet outgoing interface to incomming interface
> for tcp v4. This has few benefits:
> 1. tcp_v6_send_reset already did that.

I dont think so. ipv6 makes no special provision for RST.

> 2. This helps tcp connect with SO_BINDTODEVICE set. When connection
> is lost, we still able to sending out RST using same interface.

I dont understand this.

> 3. limit RST traffic in ingress interface reduce the impact of
> RST attack.
>=20

I dont understand this.

Me confused.

Why RST are special and should bypass/force routing decisions ?

This is going to break some setups.
