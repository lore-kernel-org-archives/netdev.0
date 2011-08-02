From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: updates to privacy addresses per RFC 4941.
Date: Mon, 01 Aug 2011 18:05:14 -0700 (PDT)
Message-ID: <20110801.180514.287177576866682423.davem@davemloft.net>
References: <20110726235049.6D52516A59B@drone1.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org, jpa@google.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50139 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753605Ab1HBBGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 21:06:19 -0400
In-Reply-To: <20110726235049.6D52516A59B@drone1.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: lorenzo@google.com (Lorenzo Colitti)
Date: Tue, 26 Jul 2011 16:50:49 -0700 (PDT)

> Update the code to handle some of the differences between
> RFC 3041 and RFC 4941, which obsoletes it. Also a couple
> of janitorial fixes.
> 
> - Allow router advertisements to increase the lifetime of
>   temporary addresses. This was not allowed by RFC 3041,
>   but is specified by RFC 4941. It is useful when RA
>   lifetimes are lower than TEMP_{VALID,PREFERRED}_LIFETIME:
>   in this case, the previous code would delete or deprecate
>   addresses prematurely.
> 
> - Change the default of MAX_RETRY to 3 per RFC 4941.
> 
> - Add a comment to clarify that the preferred and valid
>   lifetimes in inet6_ifaddr are relative to the timestamp.
> 
> - Shorten lines to 80 characters in a couple of places.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Queued up for net-next, thanks!
