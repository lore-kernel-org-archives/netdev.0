From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6 2/6] bonding: register slave pointer for
 rx_handler
Date: Wed, 16 Mar 2011 12:52:04 -0700 (PDT)
Message-ID: <20110316.125204.28814817.davem@davemloft.net>
References: <1299935679-18135-1-git-send-email-jpirko@redhat.com>
	<1299935679-18135-3-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net, xiaosuo@gmail.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47993
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751561Ab1CPTva convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2011 15:51:30 -0400
In-Reply-To: <1299935679-18135-3-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jiri Pirko <jpirko@redhat.com>
Date: Sat, 12 Mar 2011 14:14:35 +0100

> Register slave pointer as rx_handler data. That would eventually prev=
ent
> need to loop over slave devices to find the right slave.
>=20
> Use synchronize_net to ensure that bond_handle_frame does not get sla=
ve
> structure freed when working with that.
>=20
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

Applied.
