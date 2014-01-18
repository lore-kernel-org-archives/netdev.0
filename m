From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: IGMP joins come from the wrong SA/interface
Date: Sat, 18 Jan 2014 20:17:13 +0100
Message-ID: <20140118191713.GA31054@sesse.net>
References: <20140118191107.GA21979@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:54270 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbaARTRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 14:17:15 -0500
Received: from pannekake.samfundet.no ([2001:67c:29f4::50] ident=unknown)
	by cassarossa.samfundet.no with esmtps (TLS1.2:DHE_RSA_AES_128_CBC_SHA1:128)
	(Exim 4.80)
	(envelope-from <sesse@samfundet.no>)
	id 1W4bOL-0002yk-KP
	for netdev@vger.kernel.org; Sat, 18 Jan 2014 20:17:14 +0100
Received: from sesse by pannekake.samfundet.no with local (Exim 4.80)
	(envelope-from <sesse@samfundet.no>)
	id 1W4bOL-0008LV-4m
	for netdev@vger.kernel.org; Sat, 18 Jan 2014 20:17:13 +0100
Content-Disposition: inline
In-Reply-To: <20140118191107.GA21979@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 18, 2014 at 08:11:07PM +0100, Steinar H. Gunderson wrote:
> It doesn't even come on eth0.2. I don't actually understand which
> interface it comes up on (it doesn't show up on eth0.2, br0, or
> any of the component devices of br0), but it shows up on the
> =E2=80=9Cany=E2=80=9D device in tcpdump, and on eth0, which I don't h=
ave a single
> IPv4 address on.

Correction: It comes out on eth0.11, which is a component interface of =
br0,
and the interface where normally unicast packets would come out. So it =
would
really seem it uses the unicast route, for whatever reason.

/* Steinar */
--=20
Homepage: http://www.sesse.net/
