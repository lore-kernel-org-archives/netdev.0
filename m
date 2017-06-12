From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] proc: snmp6: Use correct type in memset
Date: Mon, 12 Jun 2017 09:53:56 -0400 (EDT)
Message-ID: <20170612.095356.1189085328198960046.davem@davemloft.net>
References: <20170612080657.GB1536@cell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hejianet@gmail.com
To: christian.perle@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60450 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751990AbdFLNx6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 09:53:58 -0400
In-Reply-To: <20170612080657.GB1536@cell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Perle <christian.perle@secunet.com>
Date: Mon, 12 Jun 2017 10:06:57 +0200

> Reading /proc/net/snmp6 yields bogus values on 32 bit kernels.
> Use "u64" instead of "unsigned long" in sizeof().
> 
> Fixes: 4a4857b ("proc: Reduce cache miss in snmp6_seq_show")

Please use 12 significant digits of SHA1-ID in Fixes: tags, I fixed
it up for you this time.

> Signed-off-by: Christian Perle <christian.perle@secunet.com>

Applied and queued up for -stable, thanks.
