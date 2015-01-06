From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 1/5] rhashtable: optimize rhashtable_lookup
 routine
Date: Tue, 6 Jan 2015 09:13:31 +0000
Message-ID: <20150106091331.GA12468@casper.infradead.org>
References: <1420529003-22244-1-git-send-email-ying.xue@windriver.com>
 <1420529003-22244-2-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	erik.hugne@ericsson.com, tipc-discussion@lists.sourceforge.net
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:52843 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754524AbbAFJNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 04:13:34 -0500
Content-Disposition: inline
In-Reply-To: <1420529003-22244-2-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/15 at 03:23pm, Ying Xue wrote:
> Define an internal compare function and relevant compare argument,
> and then make use of rhashtable_lookup_compare() to lookup key in
> hash table, reducing duplicated code between rhashtable_lookup()
> and rhashtable_lookup_compare().
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Cc: Thomas Graf <tgraf@suug.ch>

Acked-by: Thomas Graf <tgraf@suug.ch>
