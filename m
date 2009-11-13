From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] vlan: GRO rx statistics
Date: Fri, 13 Nov 2009 17:44:46 +0100
Message-ID: <4AFD8CFE.6090500@gmail.com>
References: <4AF99A50.5080301@gmail.com> <4AFD8C31.10703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39659 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756376AbZKMQox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 11:44:53 -0500
In-Reply-To: <4AFD8C31.10703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :

> Still the race while updating dev->stats.tx_{bytes|packets} should be=
 addressed eventually...

Sorry, I meant dev->stats.rx_{bytes|packets}, since tx side is protecte=
d by txq spinlock.

