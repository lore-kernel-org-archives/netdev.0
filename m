From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 4/5] rhashtable: involve
 rhashtable_lookup_insert routine
Date: Tue, 6 Jan 2015 09:41:17 +0000
Message-ID: <20150106094117.GD12468@casper.infradead.org>
References: <1420529003-22244-1-git-send-email-ying.xue@windriver.com>
 <1420529003-22244-5-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	erik.hugne@ericsson.com, tipc-discussion@lists.sourceforge.net
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53006 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754380AbbAFJlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 04:41:18 -0500
Content-Disposition: inline
In-Reply-To: <1420529003-22244-5-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/15 at 03:23pm, Ying Xue wrote:
> Involve a new function called rhashtable_lookup_insert() which makes
> lookup and insertion atomic under bucket lock protection, helping us
> avoid to introduce an extra lock when we search and insert an object
> into hash table.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

LGTM now, thanks!
Acked-by: Thomas Graf <tgraf@suug.ch>
