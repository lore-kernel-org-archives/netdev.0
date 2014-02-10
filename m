From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net 0/9] bridge: Fix corner case problems around
 local fdb entries
Date: Mon, 10 Feb 2014 14:36:01 -0800 (PST)
Message-ID: <20140210.143601.844510611024679530.davem@davemloft.net>
References: <1391759306-24956-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, vyasevic@redhat.com,
	netdev@vger.kernel.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56541 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791AbaBJWgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 17:36:02 -0500
In-Reply-To: <1391759306-24956-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Fri,  7 Feb 2014 16:48:17 +0900

> There are so many corner cases that are not handled properly around local
> fdb entries.
> - We might fail to delete the old entry and might delete an arbitrary local
>   entry when changing mac address of a bridge port.
> - We always fail to delete the old entry when changing mac address of the
>   bridge device.
> - We might incorrectly delete a necessary entry when detaching a bridge port.
> - We might incorrectly delete a necessary entry when deleting a vlan.
> and so on.
> 
> This is a patch series to fix these issues.

Series applied, thanks.
