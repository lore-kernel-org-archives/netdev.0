From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: unbreak build lacking CONFIG_XFRM
Date: Wed, 26 Jul 2017 09:43:18 -0700 (PDT)
Message-ID: <20170726.094318.104159181289035095.davem@davemloft.net>
References: <201707260327.pfv8cNFg%fengguang.wu@intel.com>
        <b8448ef348e62558d3ab92468e1e5ed076d66afe.1501061474.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul@paul-moore.com, kbuild-all@01.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49654 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750970AbdGZQnS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 12:43:18 -0400
In-Reply-To: <b8448ef348e62558d3ab92468e1e5ed076d66afe.1501061474.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Wed, 26 Jul 2017 11:33:49 +0200

> We must use pre-processor conditional block or suitable accessors to
> manipulate skb->sp elsewhere builds lacking the CONFIG_XFRM will break.
> 
> Fixes: dce4551cb2ad ("udp: preserve head state for IP_CMSG_PASSSEC")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, thank you.
