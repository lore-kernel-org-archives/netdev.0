From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] cleanups in drivers/net/wan/ - kfree of NULL pointer is
 valid
Date: Tue, 3 May 2005 14:32:42 -0700
Message-ID: <20050503143242.3d06f71f.davem@davemloft.net>
References: <Pine.LNX.4.62.0504290009310.2476@dragon.hyggekrogen.localhost>
	<20050428222330.GI26945@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: juhl-lkml@dif.dk, netdev@oss.sgi.com, reginak@cyclades.com,
	pc300@cyclades.com, ncorbic@sangoma.com, eis@baty.hanse.de,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20050428222330.GI26945@conectiva.com.br>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 28 Apr 2005 19:23:30 -0300
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> Em Fri, Apr 29, 2005 at 12:22:22AM +0200, Jesper Juhl escreveu:
> > kfree(0) is perfectly valid, checking pointers for NULL before calling 
> > kfree() on them is redundant. The patch below cleans away a few such 
> > redundant checks (and while I was around some of those bits I couldn't 
> > stop myself from making a few tiny whitespace changes as well).
> 
> 
> Acked-by: Arnaldo Carvalho de MElo <acme@ghostprotocols.net>

Applied, thanks everyone.

