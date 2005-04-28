From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] cleanups in drivers/net/wan/ - kfree of NULL pointer is valid
Date: Thu, 28 Apr 2005 19:23:30 -0300
Message-ID: <20050428222330.GI26945@conectiva.com.br>
References: <Pine.LNX.4.62.0504290009310.2476@dragon.hyggekrogen.localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
	Regina Kodato <reginak@cyclades.com>, pc300@cyclades.com,
	Nenad Corbic <ncorbic@sangoma.com>,
	Henner Eisen <eis@baty.hanse.de>, linux-net@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Jesper Juhl <juhl-lkml@dif.dk>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0504290009310.2476@dragon.hyggekrogen.localhost>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Fri, Apr 29, 2005 at 12:22:22AM +0200, Jesper Juhl escreveu:
> kfree(0) is perfectly valid, checking pointers for NULL before calling 
> kfree() on them is redundant. The patch below cleans away a few such 
> redundant checks (and while I was around some of those bits I couldn't 
> stop myself from making a few tiny whitespace changes as well).


Acked-by: Arnaldo Carvalho de MElo <acme@ghostprotocols.net>
