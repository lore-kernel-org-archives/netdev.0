From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_tunnel: fix panic in ip_tunnel_xmit()
Date: Mon, 03 Feb 2014 13:03:09 -0800 (PST)
Message-ID: <20140203.130309.1340651554312620948.davem@davemloft.net>
References: <CA+ydwtpmFbhkck9z8G7tfHQZW+4rWSepQMgPURqVCwrZ77v2bA@mail.gmail.com>
	<CA+ydwto5CTDSED=pZ_DfAZyh6Jx7xKJafRuDFUtV4ZZCb70ULA@mail.gmail.com>
	<1391460734.28432.111.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tt.rantala@gmail.com, netdev@vger.kernel.org, davej@redhat.com,
	trinity@vger.kernel.org, linux-kernel@vger.kernel.org,
	therbert@google.com, maze@google.com
To: eric.dumazet@gmail.com
Return-path: <trinity-owner@vger.kernel.org>
In-Reply-To: <1391460734.28432.111.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: trinity-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 03 Feb 2014 12:52:14 -0800

> From: Eric Dumazet <edumazet@google.com>
>=20
> Setting rt variable to NULL at the beginning of ip_tunnel_xmit()
> missed possible use of this variable as a scratch value.
>=20
> Also fixes a possible dst leak in tunnel_dst_check() :
> If we had to call tunnel_dst_reset(), we forgot to
> release the reference on dst.
>=20
> Merges tunnel_dst_get()/tunnel_dst_check() into
> a single tunnel_rtable_get() function for clarity.
>=20
> Many thanks to Tommi for his report and tests.
>=20
> Fixes: 7d442fab0a67 ("ipv4: Cache dst in tunnels)"
> Reported-by: Tommi Rantala <tt.rantala@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Tommi Rantala <tt.rantala@gmail.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Maciej =AFenczykowski <maze@google.com>

Applied, thanks Eric.
