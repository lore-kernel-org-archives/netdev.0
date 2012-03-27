From: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] cdc-phonet: fix skb truesize underestimation
Date: Tue, 27 Mar 2012 16:22:41 +0300
Message-ID: <2144840.57ctts9mel@hector>
References: <1332853442.3248.15.camel@edumazet-laptop> <1332854246.3248.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Felipe Balbi <balbi@ti.com>
To: ext Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.128.26]:22461 "EHLO mgw-da02.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751431Ab2C0NWv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 09:22:51 -0400
In-Reply-To: <1332854246.3248.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 mars 2012 06:17:26 ext Eric Dumazet a =E9crit :
> Now skb_add_rx_frag() has a truesize parameter, we can fix cdc-phonet=
 to
> properly account truesize of each fragment : a full page.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Felipe Balbi <balbi@ti.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Acked-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
