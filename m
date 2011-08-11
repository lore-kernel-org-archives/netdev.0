From: Julia Lawall <julia@diku.dk>
Subject: Re: [PATCH] net/netlabel/netlabel_kapi.c: add missing cleanup code
Date: Thu, 11 Aug 2011 11:52:41 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1108111152130.18938@ask.diku.dk>
References: <1313055633-25327-1-git-send-email-julia@diku.dk>
 <20110811094407.GG3777@shale.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Paul Moore <paul@paul-moore.com>, kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:33926 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754941Ab1HKJwr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 05:52:47 -0400
In-Reply-To: <20110811094407.GG3777@shale.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Aug 2011, Dan Carpenter wrote:

> On Thu, Aug 11, 2011 at 11:40:33AM +0200, Julia Lawall wrote:
> > From: Julia Lawall <julia@diku.dk>
> > 
> > Use the same cleanup code for the failure of kzalloc as for the failure of
> > kstrdup just below.
> > 
> 
> That doesn't work.  The kfree(entry->domain) would cause an oops.

Of course...  Thanks!

julia
