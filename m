From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: avoid overflow of offset in
 ip6_find_1stfragopt
Date: Wed, 19 Jul 2017 22:50:51 -0700 (PDT)
Message-ID: <20170719.225051.645203803095342.davem@davemloft.net>
References: <0f29f7f5eeb18d49879cf18a868fd36dc4d87c52.1500479911.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52446 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750771AbdGTFuw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 01:50:52 -0400
In-Reply-To: <0f29f7f5eeb18d49879cf18a868fd36dc4d87c52.1500479911.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Wed, 19 Jul 2017 22:28:55 +0200

> In some cases, offset can overflow and can cause an infinite loop in
> ip6_find_1stfragopt(). Make it unsigned int to prevent the overflow, and
> cap it at IPV6_MAXPLEN, since packets larger than that should be invalid.
> 
> This problem has been here since before the beginning of git history.
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
