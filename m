From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 4 bytes kernel memory disclosure in SO_BSDCOMPAT gsopt
Date: Wed, 11 Feb 2009 13:45:44 -0800 (PST)
Message-ID: <20090211.134544.171113049.davem@davemloft.net>
References: <op.uo6zs6xiw20ydt@clem1.netasq.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: clement.lecigne@netasq.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48588
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754894AbZBKVpu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Feb 2009 16:45:50 -0500
In-Reply-To: <op.uo6zs6xiw20ydt@clem1.netasq.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Cl=E9ment LECIGNE <clement.lecigne@netasq.com>
Date: Wed, 11 Feb 2009 15:56:56 +0100

> Hello lkml,
>=20
> In function sock_getsockopt() located in net/core/sock.c, optval v.va=
l is not correctly initialized and directly returned in userland in cas=
e we have SO_BSDCOMPAT option set.
>=20
> This dummy code should trigger the bug:

Some problems with your patch:

1) Your patch doesn't apply properly.  It has been corrupted.

   Somehow, even though you used an attachment, tab characters were
   transformed into spaces.

2) Networking patches should be sent with at least
   netdev@vger.kernel.org CC:'d so that your patch gets
   properly traced at http://patchwork.ozlabs.org/project/netdev/list/

3) You need to provide a proper "Signed-off-by:" line with your
   patch description.  See linux/Documentation/SubmittingPatches
   for details.

Please fix these issues up and resubmit your patch.

Thank you.

