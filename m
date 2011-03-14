From: Michael Smith <msmith@cbnco.com>
Subject: Re: [PATCH] Disable rp_filter for IPsec packets
Date: Mon, 14 Mar 2011 17:29:43 -0400
Message-ID: <4D7E88C7.5080706@cbnco.com>
References: <1300137299-28161-1-git-send-email-msmith@cbnco.com> <20110314.142520.28811818.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cbnco.com ([207.164.182.72]:44653 "EHLO smtp.cbnco.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751983Ab1CNVh5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 17:37:57 -0400
Received: from localhost (localhost [127.0.0.1])
	by smtp.cbnco.com (Postfix) with ESMTP id 07BCAA8855B
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 17:29:45 -0400 (EDT)
Received: from smtp.cbnco.com ([127.0.0.1])
 by localhost (mail.cbnco.com [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 06380-04 for <netdev@vger.kernel.org>;
 Mon, 14 Mar 2011 17:29:44 -0400 (EDT)
Received: from [172.20.22.83] (dmzgw2.cbnco.com [207.164.182.65])
	by smtp.cbnco.com (Postfix) with ESMTPSA id B61C7A8840F
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 17:29:44 -0400 (EDT)
In-Reply-To: <20110314.142520.28811818.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> First, I'm only willing to accept a patch like this to net-next-2.6
> for which all of the code you are changing is radically different.

OK.

> Secondly, fib_validate_source() already takes too many damn arguments.
> Find another, less costly, way to pass this information down there.

What would be a less costly way to pass it? Could I just hand it the 
whole skb?

> Frankly, I think RPF should be disabled completely by default.  When
> it doesn't do anything useful, it's making route lookups twice as
> expensive as they need to be.

Yeah, it's disabled by default. It's an easy way of preventing spoofing 
of internal source addresses from the Internet, so I like it.

Thanks,
Mike
