From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: [PATCH] resource release cleanup in net/
Date: Sat, 30 Apr 2005 18:26:45 -0300
Message-ID: <39e6f6c705043014264eb4c0c5@mail.gmail.com>
References: <Pine.LNX.4.62.0504302219520.2094@dragon.hyggekrogen.localhost>
Reply-To: acme@ghostprotocols.net
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Jouni Malinen <jkmaline@cc.hut.fi>,
	James Morris <jmorris@intercode.com.au>,
	Pedro Roque <roque@di.fc.ul.pt>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Kunihiro Ishiguro <kunihiro@ipinfusion.com>,
	Mitsuru KANDA <mk@linux-ipv6.org>,
	lksctp-developers@lists.sourceforge.net,
	Andy Adamson <andros@umich.edu>,
	Bruce Fields <bfields@umich.edu>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Jesper Juhl <juhl-lkml@dif.dk>
In-Reply-To: <Pine.LNX.4.62.0504302219520.2094@dragon.hyggekrogen.localhost>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/30/05, Jesper Juhl <juhl-lkml@dif.dk> wrote:
> Hi David,
> 
> Since Andrew merged the patch that makes calling crypto_free_tfm() with a
> NULL pointer safe into 2.6.12-rc3-mm1, I made a patch to remove checks for
> NULL before calling that function, and while I was at it I removed similar
> redundant checks before calls to kfree() and vfree() in the same files.
> There are also a few tiny whitespace cleanups in there.

Jesper, I'd suggest that you left whitespaces for a separate patch, it
is always,
IMHO, better to have as small a patch as possible for reviewing.

- Arnaldo
