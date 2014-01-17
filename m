From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH-next v2] net/ipv4: don't use module_init in non-modular
 gre_offload
Date: Thu, 16 Jan 2014 16:09:17 -0800 (PST)
Message-ID: <20140116.160917.355730401262312217.davem@davemloft.net>
References: <1389802795-27442-1-git-send-email-paul.gortmaker@windriver.com>
	<1389909911.31367.425.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, netdev@vger.kernel.org,
	edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434AbaAQAJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 19:09:18 -0500
In-Reply-To: <1389909911.31367.425.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 Jan 2014 14:05:11 -0800

> On Wed, 2014-01-15 at 11:19 -0500, Paul Gortmaker wrote:
>> Recent commit 438e38fadca2f6e57eeecc08326c8a95758594d4
>> ("gre_offload: statically build GRE offloading support") added
>> new module_init/module_exit calls to the gre_offload.c file.
> ...
>> Cc: Eric Dumazet <edumazet@google.com>
>> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
>> ---
>> 
>> v2: dump gre_offload_exit entirely as suggested by Eric.
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thank you.
