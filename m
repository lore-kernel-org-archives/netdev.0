From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6 v2] bonding: allow resetting slave failure
 counters
Date: Wed, 01 Jun 2011 13:12:43 -0700 (PDT)
Message-ID: <20110601.131243.2063791013719464193.davem@davemloft.net>
References: <20110601163153.GB2784@psychotron.redhat.com>
	<4DE6919F.3030304@gmail.com>
	<20110601200854.GD2784@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.2p.debian@gmail.com, fubar@us.ibm.com, fbl@redhat.com,
	netdev@vger.kernel.org, andy@greyhouse.net
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38415 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444Ab1FAUMv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 16:12:51 -0400
In-Reply-To: <20110601200854.GD2784@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 1 Jun 2011 22:08:55 +0200

> Wed, Jun 01, 2011 at 09:23:11PM CEST, nicolas.2p.debian@gmail.com wro=
te:
>>Le 01/06/2011 18:31, Jiri Pirko a =E9crit :
>>>This patch allows to reset failure counters for all enslaved devices=
=2E
>>
>>Hi Jiri,
>>
>>Why do we need a way to reset those counters? What is the problem
>>with having those counters monotonically increase until the system is
>>rebooted? Do we have a way to reset other network statistics
>>(/sys/class/net/eth0/statistics/* for example)?
>=20
> Well, it's handy to be able to clear this counters when you resolve
> a problem so future issues are crearly seen as non-zero.				  =20

We don't allow this in any way for netdev counters, for good reasons,
so please don't add things like this.

