From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPv4]: More fib_alias insertion fixes
Date: Mon, 27 Sep 2004 12:12:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927121240.2aea6f1d.davem@davemloft.net>
References: <Pine.LNX.4.58.0409252249150.1175@u.domain.uli>
	<20040925201425.16fbcb6c.davem@davemloft.net>
	<16727.65341.747293.986870@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16727.65341.747293.986870@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Sep 2004 13:53:33 +0200
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

> I'll guess struct fib_alias should not be defined in fib_hash.c to 
> support pluggable lookup algorithms.

Yes, all the fib_alias handling can move into fib_semantics()
in fact.  I'll work on that.
