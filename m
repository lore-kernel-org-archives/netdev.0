From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH] Right prototype of __raw_v4_lookup()
Date: Mon, 19 Jun 2006 02:34:56 +0100
Message-ID: <20060619013456.GH27946@ftp.linux.org.uk>
References: <20060527210932.GB7267@martell.zuzino.mipt.ru> <20060605.210707.39159307.davem@davemloft.net> <20060607113839.GA7268@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:6077 "EHLO
	ZenIV.linux.org.uk") by vger.kernel.org with ESMTP id S1750824AbWFSBe6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jun 2006 21:34:58 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
Content-Disposition: inline
In-Reply-To: <20060607113839.GA7268@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 07, 2006 at 03:38:39PM +0400, Alexey Dobriyan wrote:
> I think, yes. Al Viro is sitting on terabytes of endian annotations in
> networking code. See net-endian.b* branches at
> git://git.kernel.org/pub/scm/linux/kernel/git/viro/bird.git
> I don't know if he considers them ready.

I do not.  I _am_ going to finish that in this cycle, though; this stuff
got stalled on some sparse modifications needed to teach the sucker how
to deal with the next biggest bunch of annotation problems.  Need to
sort that out first; I do know how to deal with that mess, just need to
find time and do so.
