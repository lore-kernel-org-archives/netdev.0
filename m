From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] checksum: remove duplicated line of code in csum_fold
Date: Tue, 12 Feb 2013 18:41:44 +0100
Message-ID: <20130212174143.GA24888@localhost>
References: <1360689003-21794-1-git-send-email-pablo@netfilter.org>
 <20130212.121235.1398926681356889354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, arnd@arndb.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slan-550-85.anhosting.com ([174.127.110.175]:61208 "EHLO
	slan-550-85.anhosting.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S932151Ab3BLRls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 12:41:48 -0500
Content-Disposition: inline
In-Reply-To: <20130212.121235.1398926681356889354.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 12, 2013 at 12:12:35PM -0500, David Miller wrote:
> From: pablo@netfilter.org
> Date: Tue, 12 Feb 2013 18:10:03 +0100
> 
> > From: Pablo Neira Ayuso <pablo@netfilter.org>
> > 
> > Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> I am very sure that those two lines are there intentionally.
> The first addition one can overflow, therefore we need to
> fold again (which cannot overflow).

I was missing that, make sense indeed, thanks.
