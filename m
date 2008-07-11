From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/6] via-velocity: remove the bounce buffers
Date: Fri, 11 Jul 2008 01:14:04 -0400
Message-ID: <4876EC1C.4080705@garzik.org>
References: <20080710220344.GB29764@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?ISO-8859-1?Q?S=E9guier_R=E9gis?= <rseguier@e-teleport.net>,
	akpm@linux-foundation.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46466 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750886AbYGKFOM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 01:14:12 -0400
In-Reply-To: <20080710220344.GB29764@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rancois Romieu wrote:
> Executive summary: the bounce buffers are in my way
>=20
> - they use something like a 64 * 1500 bytes area of PCI
>   consistent area
> - they are not resized when the MTU changes
> - they are used
>   - to hand-pad undersized packets. skb_pad anyone ?
>   - to linearize fragmented skbs whose fragment count
>     goes beyond the 7 fragments hardware limit in order
>     to claim scatter-gather support
>=20
> Actually the SG code is commented out and I wonder if it
> could not be implemented (ab-)using the large send feature
> of the chipset since the latter should support some
> multi-descriptor packet transmitting.
>=20
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Fixed-by: S=E9guier R=E9gis <rseguier@e-teleport.net>
> ---
>  drivers/net/via-velocity.c |   72 +++++++++++-----------------------=
----------
>  drivers/net/via-velocity.h |    5 ---
>  2 files changed, 18 insertions(+), 59 deletions(-)
>=20

ACK patches 1-6

applied 1-4, patch #5 failed to apply


