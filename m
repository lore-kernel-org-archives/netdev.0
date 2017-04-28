From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rhashtable: Do not lower max_elems when
 max_size is zero
Date: Fri, 28 Apr 2017 10:14:49 -0400 (EDT)
Message-ID: <20170428.101449.1468521013732143831.davem@davemloft.net>
References: <56843a86-9a09-16e8-acec-05a80396f282@gmail.com>
        <20170427223024.32657-1-f.fainelli@gmail.com>
        <20170428061048.GA6817@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, fw@strlen.de,
        tgraf@suug.ch
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54598 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756458AbdD1OOx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 10:14:53 -0400
In-Reply-To: <20170428061048.GA6817@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 28 Apr 2017 14:10:48 +0800

> The commit 6d684e54690c ("rhashtable: Cap total number of entries
> to 2^31") breaks rhashtable users that do not set max_size.  This
> is because when max_size is zero max_elems is also incorrectly set
> to zero instead of 2^31.
> 
> This patch fixes it by only lowering max_elems when max_size is not
> zero.
> 
> Fixes: 6d684e54690c ("rhashtable: Cap total number of entries to 2^31")
> Reported-by: Florian Fainelli <f.fainelli@gmail.com>
> Reported-by: kernel test robot <fengguang.wu@intel.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
