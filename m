From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: netlink locking warnings in 2.6.21-rc7-mm1
Date: Wed, 25 Apr 2007 16:48:16 -0700
Message-ID: <20070425164816.89284b5c.akpm@linux-foundation.org>
References: <E1HgVxj-0003U6-00@gondolin.me.apana.org.au>
	<462F54F3.9050306@trash.net>
	<20070425124449.98bf091c.akpm@linux-foundation.org>
	<462FBF5F.20909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:51134 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1422931AbXDYXs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 19:48:56 -0400
In-Reply-To: <462FBF5F.20909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Apr 2007 22:51:43 +0200 Patrick McHardy <kaber@trash.net> wrote:

> I think I found the problem, the rtnl_mutex was reinitialized on every
> rtnetlink socket creation. This is most likely responsible for both
> warnings.

Yup, no warnings any more, thanks.
