From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] IPv6: enable bind() to assign an anycast
 address
Date: Mon, 17 Feb 2014 14:48:58 -0500 (EST)
Message-ID: <20140217.144858.1324303687260941756.davem@davemloft.net>
References: <CAMrnHh5osKyOpmObYmWNswZuxYAc0SYUrmfohkg2GaafKmPK0w@mail.gmail.com>
	<20140217.141949.1387848185062797150.davem@davemloft.net>
	<1392666165.65245.YahooMailNeo@web125505.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kuznet@ms2.inr.ac.ru, christoph.paasch@uclouvain.be,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: fx.lebail@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50598 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753238AbaBQTtB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 14:49:01 -0500
In-Reply-To: <1392666165.65245.YahooMailNeo@web125505.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com>
Date: Mon, 17 Feb 2014 11:42:45 -0800 (PST)

> If I understand well the reviews, no change was ask for this patch.
> The sysctl was asked in case of patch for TCP.
> So, why the status is now "Changes Requested" ?=20

This change is in generic bind() code, therefore it allows binding TCP
sockets with anycast, therefore you need to make a change.
