From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/5] net: dsa: tagger simplification
Date: Thu, 01 Jun 2017 17:36:21 -0400 (EDT)
Message-ID: <20170601.173621.2175012266174522011.davem@davemloft.net>
References: <20170601200715.8438-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60570 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751050AbdFAVgZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 17:36:25 -0400
In-Reply-To: <20170601200715.8438-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu,  1 Jun 2017 16:07:10 -0400

> This series clarifies the hot path, removes the labels in tagging
> implementations, and frees the original SKB in the xmit caller.
> 
> Changes in v3:
>   - drop removal of usused rcv arguments because they will be used later
>   - include the new ksz tagging implementation
>   - add reviewers' tags
> 
> Changes in v2:
>   - do not remove tagger function copies
>   - document hot path requirements
>   - make netdev_uses_dsa simpler
>   - add reviewers' tags

Series applied, thanks Vivien.
