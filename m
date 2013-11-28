From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH v2] diag: warn about missing first netlink attribute
Date: Thu, 28 Nov 2013 22:09:09 +0000
Message-ID: <20131128220909.GA4100@casper.infradead.org>
References: <20131128163816.GA32047@casper.infradead.org>
 <1385659865-1926-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:60492 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab3K1WJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 17:09:11 -0500
Content-Disposition: inline
In-Reply-To: <1385659865-1926-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/13 at 06:31pm, Nicolas Dichtel wrote:
> The first netlink attribute (value 0) must always be defined as none/unspec.
> This is correctly done in inet_diag.h, but other diag interfaces are wrong.
> 
> Because we cannot change an existing API, I add a comment to point the mistake
> and avoid to propagate it in a new diag API in the future.
> 
> CC: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> 
> v2: just warn about the missing attribute
> 
> If patch is approved, I will submit it when the net-next tree opens.

Acked-by: Thomas Graf <tgraf@suug.ch>
