From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] ipv4/netfilter: remove unnecessary goto
 statement for error recovery
Date: Thu, 23 Aug 2012 00:33:12 +0200
Message-ID: <20120822223312.GB11141@1984>
References: <1345425092-11905-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58203 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030193Ab2HVWdQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2012 18:33:16 -0400
Content-Disposition: inline
In-Reply-To: <1345425092-11905-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 19, 2012 at 07:11:32PM -0600, Jean Sacren wrote:
> Usually it's a good practice to use goto statement for error recovery
> when initializing the module. This approach could be an overkill if:
> 
>  1) there is only one fail case;
>  2) success and failure use the same return statement.
> 
> For a cleaner approach, remove the unnecessary goto statement and
> directly implement error recovery.

Applied, thanks Jean.
