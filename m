From: David Miller <davem@davemloft.net>
Subject: Re: [patch] farsync: fix info leak in ioctl
Date: Fri, 11 Oct 2013 17:55:47 -0400 (EDT)
Message-ID: <20131011.175547.1829828126032052990.davem@davemloft.net>
References: <5257BFBA.7030405@ai2.upv.es>
	<20131011095003.GD6247@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kevin.curtis@farsite.co.uk, speiro@ai2.upv.es, security@kernel.org,
	netdev@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56375 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755322Ab3JKVzs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 17:55:48 -0400
In-Reply-To: <20131011095003.GD6247@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 11 Oct 2013 12:50:03 +0300

> From: Salva Peir=F3 <speiro@ai2.upv.es>
>=20
> The fst_get_iface() code fails to initialize the two padding bytes of
> struct sync_serial_settings after the ->loopback member. Add an expli=
cit
> memset(0) before filling the structure to avoid the info leak.
>=20
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied and queued up for -stable.
