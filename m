From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] Netfilter/nf_tables fixes for net-next
Date: Thu, 05 Jun 2014 15:35:21 -0700 (PDT)
Message-ID: <20140605.153521.2289697483630879773.davem@davemloft.net>
References: <1401980906-25290-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752631AbaFEWfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 18:35:23 -0400
In-Reply-To: <1401980906-25290-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu,  5 Jun 2014 17:08:20 +0200

> This patchset contains fixes for recent updates available in your
> net-next, they are:
> 
> 1) Fix double memory allocation for accounting objects that results
>    in a leak, this slipped through with the new quota extension,
>    patch from Mathieu Poirier.
> 
> 2) Fix broken ordering when adding set element transactions.
> 
> 3) Make sure that objects are released in reverse order in the abort
>    path, to avoid possible use-after-free when accessing dependencies.
> 
> 4) Allow to delete several objects (as long as dependencies are
>    fulfilled) by using one batch. This includes changes in the use
>    counter semantics of the nf_tables objects.
> 
> 5) Fix illegal sleeping allocation from rcu callback.

Pulled, thanks a lot Pablo.
