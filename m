From: "David S. Miller" <davem@davemloft.net>
Subject: Re: IPsec performance
Date: Tue, 3 May 2005 12:27:44 -0700
Message-ID: <20050503122744.1e5cafcf.davem@davemloft.net>
References: <Pine.GSO.4.58.0505022117190.25766@kekkonen.cs.hut.fi>
	<Pine.GSO.4.58.0505022204090.25766@kekkonen.cs.hut.fi>
	<Pine.LNX.4.62.0505030248020.26815@kaber.coreworks.de>
	<Pine.GSO.4.58.0505030820160.24686@kekkonen.cs.hut.fi>
	<1115099678.2953.3.camel@ori.thedillows.org>
	<Pine.GSO.4.58.0505030943310.247@kekkonen.cs.hut.fi>
	<1115129839.2953.4.camel@ori.thedillows.org>
	<Pine.GSO.4.58.0505031913020.9502@kekkonen.cs.hut.fi>
	<1115148461.31573.9.camel@dillow.idleaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: miika@iki.fi, kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dave Dillow <dave@thedillows.org>
In-Reply-To: <1115148461.31573.9.camel@dillow.idleaire.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 03 May 2005 15:27:41 -0400
Dave Dillow <dave@thedillows.org> wrote:

> I think it's been mentioned that our 3DES implementation has not been
> tuned for x86, so there's probably some performance being left on the
> floor.

That's right.  We only have an optimized AES implementation in assembler,
and that's for i386 and x86_64 platforms only.
