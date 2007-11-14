From: Marek Kierdelewicz <marek@koba.pl>
Subject: skb processing in SMP kernel
Date: Wed, 14 Nov 2007 21:14:37 +0100
Message-ID: <20071114211437.7f4c79d2@catlap>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from psyche.piasta.pl ([83.175.144.5]:39497 "EHLO psyche.piasta.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755252AbXKNUU5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 15:20:57 -0500
Received: from unknown ([127.0.0.2])
 by localhost (psyche.piasta.pl [127.0.0.2]) (amavisd-new, port 10628)
 id 27422-01 for <netdev@vger.kernel.org>;
 Wed, 14 Nov 2007 21:20:53 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there,

I'm looking at file /usr/src/linux/net/core/dev.c
function "int netif_rx(struct sk_buff *skb)"
and following line:
=20
queue =3D &__get_cpu_var(softnet_data);

Is it possible to put skb into the queue of another CPU then the one
servicing the interrupt? (Disclaimer: Yeah, I know it's probably not
the smartest thing to do because of locks and cache line bounces). How
could it be accomplished? Any lead, comment, link appreciated.


pozdrawiam
--=20
Marek Kierdelewicz
Kierownik Dzia=B3u System=F3w Sieciowych, KoBa
Manager of Network Systems Department, KoBa
tel. (85) 7406466; fax. (85) 7406467
e-mail: admin@koba.pl
