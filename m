From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [6/6]: jenkins hash for neigh / Statistics
Date: Mon, 27 Sep 2004 16:06:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927160636.7741d973.davem@davemloft.net>
References: <20040925005623.2faf8faf.davem@davemloft.net>
	<E1CBu70-00010X-00@gondolin.me.apana.org.au>
	<20040927121403.767e2308.davem@davemloft.net>
	<20040927222613.GE3236@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040927222613.GE3236@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 28 Sep 2004 00:26:13 +0200
Harald Welte <laforge@gnumonks.org> wrote:

> As stated before, I would like to change rt_stat and ct_stat in order to
> include a first 'template' line, too.  This way it is easier to write a
> generic foo_stat program, that could deal with any of those statistics
> files, even with new ones...  but this of course would break existing
> rtstat binaries.  I personally  don't care, since it's a little-known
> and little-used feature, which to my knowledge is in a lot of
> distributions either non-existant [Debian] or incompatible [SuSE]. What
> do you think?

I agree.  And while we're add it let's get a fixed rtstat into
iproute2 and make sure that binary gets installed by default
so maybe the dists will start shipping it properly.
