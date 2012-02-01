From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH v3 1/6] net: pad skb data and shinfo as a whole rather
 than individually
Date: Wed, 1 Feb 2012 10:09:49 +0000
Message-ID: <1328090989.17444.31.camel@zakaz.uk.xensource.com>
References: <1327494389.24561.316.camel@zakaz.uk.xensource.com>
	 <1327494434-21566-1-git-send-email-ian.campbell@citrix.com>
	 <1327495879.2425.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1327496953.24561.323.camel@zakaz.uk.xensource.com>
	 <1327497157.2425.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328020528.26983.396.camel@zakaz.uk.xensource.com>
	 <1328021140.2297.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328089187.17444.10.camel@zakaz.uk.xensource.com>
	 <1328090522.2595.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:3535 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753819Ab2BAKJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 05:09:51 -0500
In-Reply-To: <1328090522.2595.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-02-01 at 10:02 +0000, Eric Dumazet wrote:
> Le mercredi 01 f=C3=A9vrier 2012 =C3=A0 09:39 +0000, Ian Campbell a =C3=
=A9crit :
>=20
> > I'll investigate the sending side. The sender is running a 2.6.32 d=
istro
> > kernel. Maybe I need to tweak it somewhat.
>=20
> Thats strange, even a very old kernel is able to sustain Gigabit line
> rate with pktgen. Maybe a problem with a switch and ethernet pauses ?

Tanks, that was something I was going to investigate. These machines ar=
e
in our lab so I need to figure out if they are even directly attached t=
o
the same switch etc.

Ian.
