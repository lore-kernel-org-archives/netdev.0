From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: IGMP joins come from the wrong SA/interface
Date: Wed, 5 Feb 2014 00:34:59 +0100
Message-ID: <20140204233459.GA30008@sesse.net>
References: <20140118191107.GA21979@sesse.net>
 <20140119181806.GC16462@order.stressinduktion.org>
 <20140120184025.GA19972@sesse.net>
 <20140130104709.GA21178@sesse.net>
 <20140130180304.GA3793@plex.lan>
 <20140130181229.GA32245@sesse.net>
 <20140130224411.GG25336@order.stressinduktion.org>
 <20140204220809.GB7526@sesse.net>
 <20140204233206.GA16198@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:39899 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932981AbaBDXfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 18:35:02 -0500
Received: from pannekake.samfundet.no ([2001:67c:29f4::50] ident=unknown)
	by cassarossa.samfundet.no with esmtps (TLS1.2:DHE_RSA_AES_128_CBC_SHA1:128)
	(Exim 4.80)
	(envelope-from <sesse@samfundet.no>)
	id 1WApW7-0002Rt-Ti
	for netdev@vger.kernel.org; Wed, 05 Feb 2014 00:35:00 +0100
Received: from sesse by pannekake.samfundet.no with local (Exim 4.80)
	(envelope-from <sesse@samfundet.no>)
	id 1WApW7-0000Ef-FZ
	for netdev@vger.kernel.org; Wed, 05 Feb 2014 00:34:59 +0100
Content-Disposition: inline
In-Reply-To: <20140204233206.GA16198@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 05, 2014 at 12:32:06AM +0100, Hannes Frederic Sowa wrote:
>>  2. I didn't properly understand that the multicast flag on the rout=
e did not
>>     matter (although it really should!).
> Hmm, maybe that would be good but I am not sure if that could break e=
xisting
> setups if we change that now. It seems it is handled like that since =
Alexey
> implemented it in that way.

Thinking of it, traditionally (and by =E2=80=9Ctraditionally=E2=80=9D I=
 mean in IOS and the
likes, not Linux) the multicast routing table has been used to look up =
the
rendezvous point (RP), to know where to send the PIM join. (The leads t=
o the
confusing situation where the multicast routing table contains unicast
addresses.) In this situation, we have IGMP and not PIM, which means we=
 do
not know anything about the RP, so maybe it's the right decision after =
all.

/* Steinar */
--=20
Homepage: http://www.sesse.net/
