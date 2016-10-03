From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add netdev all_adj_list refcnt propagation to fix panic
Date: Sun, 02 Oct 2016 20:17:31 -0400 (EDT)
Message-ID: <20161002.201731.2191796054736402577.davem@davemloft.net>
References: <1475086011-5588-1-git-send-email-dsa@cumulusnetworks.com>
        <715a8d0a-9245-fd83-bf58-70f863c721f7@cradlepoint.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org, vfalico@gmail.com,
        nikolay@cumulusnetworks.com
To: acollins@cradlepoint.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36202 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751621AbcJCAST (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Oct 2016 20:18:19 -0400
In-Reply-To: <715a8d0a-9245-fd83-bf58-70f863c721f7@cradlepoint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Collins <acollins@cradlepoint.com>
Date: Wed, 28 Sep 2016 13:04:42 -0600

> On 09/28/2016 12:06 PM, David Ahern wrote:
>> Andrew Collins posted this patch as RFC in March:
>>     http://patchwork.ozlabs.org/patch/603101/
>>
>> It has apparently fallen through the cracks and never applied.
>>
>> It solves a refcnt problem (thanks Nik for pointing out this patch)
> 
> I have been running the patch in production for the past few months
> without issue, in spite of my concerns about the potential side
> effects of the change.  That said, I suspect my use cases are a subset
> of yours.
> 
> If nobody has a better fix yet, I'm happy to respin this patch as
> non-RFC with proper signoff.

Please do so.
