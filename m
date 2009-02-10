From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 00/05: netfilter fixes
Date: Mon, 09 Feb 2009 16:28:29 -0800 (PST)
Message-ID: <20090209.162829.143182391.davem@davemloft.net>
References: <4990B26B.3020705@trash.net>
	<20090209.151806.02424601.davem@davemloft.net>
	<4990BDE6.80102@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4990BDE6.80102@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 10 Feb 2009 00:36:06 +0100

> My workflow is quite out of sync with modern git commands, some of
> my scripts are still adapted from bitkeeper times :)

You poor thing, I should buy you some beer :-)

But to be honest I had a caveman like mentality about
using GIT and it took me a long time to get to the
current way I do things:

1) Dark ages:

	Fresh git clone, add patches, push to Linus.
	Repeat, rebasing every time.

2) Brain enabled:

	Stable git clone, used over and over again.

	After Linus pulls, remember HEAD and use that as
	base for next pull request.

	Pull in Linus's tree occaisionally when conflicts
	might be possible.

3) Full enlightenment:

	Stable git clone, used over and over again.

	Track Linus's tree using "git fetch origin"

	When conflicts are possible "git pull origin"

	All pull requests are sent using "origin" as
	the base.
