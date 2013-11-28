From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] diag: fix netlink API attributes
Date: Thu, 28 Nov 2013 16:38:16 +0000
Message-ID: <20131128163816.GA32047@casper.infradead.org>
References: <1385647039-1547-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:32846 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758826Ab3K1QiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 11:38:17 -0500
Content-Disposition: inline
In-Reply-To: <1385647039-1547-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/13 at 02:57pm, Nicolas Dichtel wrote:
> The first netlink attribute (value 0) must always be defined as none/unspec.
> This is correctly done in inet_diag.h, but other diag interfaces are broken.
> 
> Libraries like libnl skip this kind of attributes, thus it's never reported to
> the application.
> 
> CC: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

First of all, thanks for the notification Nicolas. I'll fix libnl to
pass through these attributes.

I think the fix you propose is no an option as it breaks backwards
compatiblity with existing user space. We cannot change the value
of existing attributes.
