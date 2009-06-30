From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.
 Now=15 size=11 bits
Date: Tue, 30 Jun 2009 12:48:49 -0700 (PDT)
Message-ID: <20090630.124849.167332569.davem@davemloft.net>
References: <20090629083315.GA4712@ff.dom.local>
	<4A488EB8.4070602@itcare.pl>
	<20090629105820.GD4712@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pstaszewski@itcare.pl, robert@robur.slu.se,
	Robert.Olsson@data.slu.se, jorge@dti2.net, dada1@cosmosbay.com,
	robert.olsson@its.uu.se, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42536
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755898AbZF3Tso convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jun 2009 15:48:44 -0400
In-Reply-To: <20090629105820.GD4712@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 29 Jun 2009 10:58:20 +0000

> On Mon, Jun 29, 2009 at 11:51:52AM +0200, Pawe=B3 Staszewski wrote:
>> I apply this patch
>>
>> fib_triestats in attached file :)
>>
>>> ------------------->
>>> ipv4: Fix fib_trie rebalancing, part 3
>>>
>>> Alas current delaying of freeing old tnodes by RCU in trie_rebalanc=
e
>>> is still not enough because we can free a top tnode before updating=
 a
>>> t->trie pointer.
>>>
>>> Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
>>> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
>>> ---
>=20
> David, I guess you could add:
>=20
> Tested-by: Pawel Staszewski <pstaszewski@itcare.pl>

Done, and applied, thanks Jarek.
