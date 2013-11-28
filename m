From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v2] diag: warn about missing first netlink attribute
Date: Thu, 28 Nov 2013 18:16:54 -0500 (EST)
Message-ID: <20131128.181654.469352290882758065.davem@davemloft.net>
References: <20131128163816.GA32047@casper.infradead.org>
	<1385659865-1926-1-git-send-email-nicolas.dichtel@6wind.com>
	<20131128220909.GA4100@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47316 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072Ab3K1XQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 18:16:55 -0500
In-Reply-To: <20131128220909.GA4100@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 28 Nov 2013 22:09:09 +0000

> On 11/28/13 at 06:31pm, Nicolas Dichtel wrote:
>> The first netlink attribute (value 0) must always be defined as none/unspec.
>> This is correctly done in inet_diag.h, but other diag interfaces are wrong.
>> 
>> Because we cannot change an existing API, I add a comment to point the mistake
>> and avoid to propagate it in a new diag API in the future.
>> 
>> CC: Thomas Graf <tgraf@suug.ch>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>> 
>> v2: just warn about the missing attribute
>> 
>> If patch is approved, I will submit it when the net-next tree opens.
> 
> Acked-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks.
