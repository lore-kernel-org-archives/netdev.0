From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rhashtable: fix missing header
Date: Sun, 04 Jan 2015 23:12:31 -0500 (EST)
Message-ID: <20150104.231231.947969955867273677.davem@davemloft.net>
References: <1420356309-7382-1-git-send-email-ying.xue@windriver.com>
	<20150104091908.GA15305@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ying.xue@windriver.com, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46478 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838AbbAEEMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 23:12:39 -0500
In-Reply-To: <20150104091908.GA15305@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Sun, 4 Jan 2015 09:19:08 +0000

> On 01/04/15 at 03:25pm, Ying Xue wrote:
>> Fixup below build error:
>> 
>> include/linux/rhashtable.h: At top level:
>> include/linux/rhashtable.h:118:34: error: field ???mutex??? has incomplete type
> 
> Just wondering, is this your new code that didn't compile? The code
> compiled fine for me for the existing users.
> 
>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> 
> Fixes: 97defe1e ("rhashtable: Per bucket locks & deferred expansion/shrinking")
> Acked-by: Thomas Graf <tgraf@suug.ch>

I'm applying this now as rhashtable.h really needs to include mutex.h
as it does use it's interfaces, regardless of whether it does actually
introduce a build error currently or not.
