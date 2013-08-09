From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pptp: fix sparse pointer warning
Date: Fri, 09 Aug 2013 14:15:19 -0700 (PDT)
Message-ID: <20130809.141519.1878285016513082225.davem@davemloft.net>
References: <20130808102714.6f16ff43@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xeb@mail.ru, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51818 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031152Ab3HIVPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 17:15:20 -0400
In-Reply-To: <20130808102714.6f16ff43@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 8 Aug 2013 10:27:14 -0700

> callid_sock array is referenced via rcu_dereference and
> sparse rcu checks complains about address space mismatch.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks.
