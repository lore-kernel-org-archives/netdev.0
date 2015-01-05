From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] rhashtable: involve
 rhashtable_lookup_insert routine
Date: Mon, 05 Jan 2015 16:30:18 -0500 (EST)
Message-ID: <20150105.163018.658637009804208069.davem@davemloft.net>
References: <1420457634-13017-1-git-send-email-ying.xue@windriver.com>
	<20150105130514.GA15499@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ying.xue@windriver.com, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60703 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753240AbbAEVaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 16:30:21 -0500
In-Reply-To: <20150105130514.GA15499@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 5 Jan 2015 13:05:14 +0000

> On 01/05/15 at 07:33pm, Ying Xue wrote:
>> Involve a new function called rhashtable_lookup_insert() which makes
>> lookup and insertion atomic under bucket lock protection, helping us
>> avoid to introduce an extra lock when we search and insert an object
>> into hash table.
>> 
>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
>> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Thanks for putting this around so quickly and thanks for testing.
> I think this looks good. You might be able to factor out some code
> from rhashtable_insert() to avoid duplication so we reduce the risk
> of fixing a bug for one function but not the other.

Do you want Ying to do this factoring out now in a v3 of this patch
or in a subsequent patch?

I assume the former since you didn't give your ACK.
