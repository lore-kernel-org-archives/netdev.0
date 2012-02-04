From: Shawn Lu <shawn.lu@ericsson.com>
Subject: RE: [PATCH] tcp: RST: binding oif to iif for tcp v4
Date: Sat, 4 Feb 2012 13:42:56 -0500
Message-ID: <62162DF05402B341B3DB59932A1FA992B5B5C9FCFC@EUSAACMS0702.eamcs.ericsson.se>
References: <1328300212-18836-1-git-send-email-shawn.lu@ericsson.com>
	 <1328304719.2480.5.camel@edumazet-laptop>
	 <62162DF05402B341B3DB59932A1FA992B5B5C9FB94@EUSAACMS0702.eamcs.ericsson.se>
	 <1328342816.2577.8.camel@edumazet-laptop>
	 <62162DF05402B341B3DB59932A1FA992B5B5C9FCF6@EUSAACMS0702.eamcs.ericsson.se>
 <1328380194.2731.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr4.ericy.com ([198.24.6.9]:46604 "EHLO imr4.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751405Ab2BDSnR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 13:43:17 -0500
In-Reply-To: <1328380194.2731.33.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric:

Yes, you are right.  It helps if we do as your suggested.

Do you want to send out a patch to address this?=20

Thanks!

Shawn
> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
> Sent: Saturday, February 04, 2012 10:30 AM
> To: Shawn Lu
> Cc: davem@davemloft.net; netdev@vger.kernel.org; xiaoclu@gmail.com
> Subject: RE: [PATCH] tcp: RST: binding oif to iif for tcp v4
>=20
> Le samedi 04 f=E9vrier 2012 =E0 13:15 -0500, Shawn Lu a =E9crit :
>=20
> > It won't work.  For RST, socket is gone.=20
>=20
> If this was true, we would not have :
>=20
> tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
>=20
> but :
>=20
> tcp_v4_send_reset(struct sk_buff *skb)
>=20
>=20
> Think about it.
>=20
> You write a lot, but you dont really understand what I wrote=20
> in my previous mails, do you ?
>=20
>=20
>=20
> 