From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv6: Fix CALIPSO causing GPF with datagram support
Date: Tue, 06 Jun 2017 15:19:19 -0400 (EDT)
Message-ID: <20170606.151919.50793178996552480.davem@davemloft.net>
References: <20170605154440.2434-1-richard_c_haines@btinternet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul@paul-moore.com, netdev@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org
To: richard_c_haines@btinternet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37186 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751449AbdFFTTc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 15:19:32 -0400
In-Reply-To: <20170605154440.2434-1-richard_c_haines@btinternet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Haines <richard_c_haines@btinternet.com>
Date: Mon,  5 Jun 2017 16:44:40 +0100

> When using CALIPSO with IPPROTO_UDP it is possible to trigger a GPF as the
> IP header may have moved.
> 
> Also update the payload length after adding the CALIPSO option.
> 
> Signed-off-by: Richard Haines <richard_c_haines@btinternet.com>

Applied and queued up for -stable, thank you Richard.
