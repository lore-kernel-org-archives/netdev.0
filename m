From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/4] rtnetlink: preparation patches for
 further rtnl lock pushdown/removal
Date: Thu, 28 Sep 2017 10:21:03 -0700 (PDT)
Message-ID: <20170928.102103.426732141334972472.davem@davemloft.net>
References: <20170926115843.12013-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49756 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751339AbdI1RVE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 13:21:04 -0400
In-Reply-To: <20170926115843.12013-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 26 Sep 2017 13:58:39 +0200

> Patches split large rtnl_fill_ifinfo into smaller chunks
> to better see which parts
> 
> 1. require rtnl
> 2. do not require it at all
> 3. rely on rtnl locking now but could be converted
> 
> Changes since v3:
> 
> I dropped the 'ifalias' patch, I have a change to decouple ifalias and
> rtnl mutex, I will send it once this series has been merged.

Series applied.
