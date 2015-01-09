From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 1/3] rhashtable: involve
 rhashtable_lookup_compare_insert routine
Date: Fri, 9 Jan 2015 10:31:42 +0000
Message-ID: <20150109103142.GA25021@casper.infradead.org>
References: <1420791818-22150-1-git-send-email-ying.xue@windriver.com>
 <1420791818-22150-2-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51687 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756194AbbAIKbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 05:31:45 -0500
Content-Disposition: inline
In-Reply-To: <1420791818-22150-2-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/15 at 04:23pm, Ying Xue wrote:
> Introduce a new function called rhashtable_lookup_compare_insert()
> which is very similar to rhashtable_lookup_insert(). But the former
> makes use of users' given compare function to look for an object,
> and then inserts it into hash table if found. As the entire process
> of search and insertion is under protection of per bucket lock, this
> can help users to avoid the involvement of extra lock.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Cc: Thomas Graf <tgraf@suug.ch>

Acked-by: Thomas Graf <tgraf@suug.ch>
