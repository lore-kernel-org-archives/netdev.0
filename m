From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] rxrpc: Disable a debugging statement that has been
 left enabled.
Date: Thu, 07 Apr 2016 13:38:43 -0400 (EDT)
Message-ID: <20160407.133843.156901424652264502.davem@davemloft.net>
References: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
	<20160407162309.21283.11482.stgit@warthog.procyon.org.uk>
	<1460046677.6715.95.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460046677.6715.95.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Joe Perches <joe@perches.com>
Date: Thu, 07 Apr 2016 09:31:17 -0700

> On Thu, 2016-04-07 at 17:23 +0100, David Howells wrote:
>> Disable a debugging statement that has been left enabled
>>=20
>> Signed-off-by: David Howells <dhowells@redhat.com>
>> ---
>>=20
>> =A0net/rxrpc/ar-ack.c |=A0=A0=A0=A02 +-
>> =A01 file changed, 1 insertion(+), 1 deletion(-)
>>=20
>> diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
>> index 16d967075eaf..01a017a05f14 100644
>> --- a/net/rxrpc/ar-ack.c
>> +++ b/net/rxrpc/ar-ack.c
>> @@ -426,7 +426,7 @@ static void rxrpc_rotate_tx_window(struct rxrpc_=
call *call, u32 hard)
>> =A0	int tail =3D call->acks_tail, old_tail;
>> =A0	int win =3D CIRC_CNT(call->acks_head, tail, call->acks_winsz);
>> =A0
>> -	kenter("{%u,%u},%u", call->acks_hard, win, hard);
>> +	_enter("{%u,%u},%u", call->acks_hard, win, hard);
>> =A0
>> =A0	ASSERTCMP(hard - call->acks_hard, <=3D, win);
>=20
> It might be better to remove kenter and _enter
> altogether and use function tracing instead.

Yeah this custom stuff is really inappropriate given the excellent
infrastructure we have these days...
