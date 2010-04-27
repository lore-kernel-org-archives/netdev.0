From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ipheth: potential null dereferences on error path
Date: Tue, 27 Apr 2010 14:49:22 -0700 (PDT)
Message-ID: <20100427.144922.176653899.davem@davemloft.net>
References: <20100427092012.GA29093@bicker>
	<20100427214347.GA2376@bart.evergreen.loc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: error27@gmail.com, diego@giagio.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: agimenez@sysvalve.es
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51207
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753988Ab0D0VtQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 17:49:16 -0400
In-Reply-To: <20100427214347.GA2376@bart.evergreen.loc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: L. Alberto Gim=E9nez <agimenez@sysvalve.es>
Date: Tue, 27 Apr 2010 23:43:47 +0200

> On Tue, Apr 27, 2010 at 11:20:12AM +0200, Dan Carpenter wrote:
>> The calls to usb_free_buffer() dereference rx_urb and tx_urb in the
>> parameter list but those could be NULL.
>>=20
>> Signed-off-by: Dan Carpenter <error27@gmail.com>
>=20
> Acked-by: L. Alberto Gim=E9nez <agimenez@sysvalve.es>

Applied, thanks everyone.
