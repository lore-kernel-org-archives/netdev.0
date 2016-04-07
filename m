From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/9] rxrpc: Disable a debugging statement that has been
 left enabled.
Date: Thu, 07 Apr 2016 09:31:17 -0700
Message-ID: <1460046677.6715.95.camel@perches.com>
References: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
	 <20160407162309.21283.11482.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0203.hostedemail.com ([216.40.44.203]:42134 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755954AbcDGQbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 12:31:21 -0400
In-Reply-To: <20160407162309.21283.11482.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-04-07 at 17:23 +0100, David Howells wrote:
> Disable a debugging statement that has been left enabled
>=20
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
>=20
> =A0net/rxrpc/ar-ack.c |=A0=A0=A0=A02 +-
> =A01 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
> index 16d967075eaf..01a017a05f14 100644
> --- a/net/rxrpc/ar-ack.c
> +++ b/net/rxrpc/ar-ack.c
> @@ -426,7 +426,7 @@ static void rxrpc_rotate_tx_window(struct rxrpc_c=
all *call, u32 hard)
> =A0	int tail =3D call->acks_tail, old_tail;
> =A0	int win =3D CIRC_CNT(call->acks_head, tail, call->acks_winsz);
> =A0
> -	kenter("{%u,%u},%u", call->acks_hard, win, hard);
> +	_enter("{%u,%u},%u", call->acks_hard, win, hard);
> =A0
> =A0	ASSERTCMP(hard - call->acks_hard, <=3D, win);

It might be better to remove kenter and _enter
altogether and use function tracing instead.
