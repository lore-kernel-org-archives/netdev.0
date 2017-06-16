From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] skb data accessors cleanup
Date: Fri, 16 Jun 2017 11:50:13 -0400 (EDT)
Message-ID: <20170616.115013.1187787408957466917.davem@davemloft.net>
References: <20170616070747.3332-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60506 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751882AbdFPPuU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 11:50:20 -0400
In-Reply-To: <20170616070747.3332-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 16 Jun 2017 09:07:42 +0200

> Over night, Fengguang's bot told me that it compiled all of its many
> various configurations successfully, and I had done allyesconfig on
> x86_64 myself yesterday to iron out the things I missed.
> 
> So now I think I'm happy with it.
> 
> My tree was based on your
> 
>     commit 3715c47bcda8bb56f7e2be27276282a2d0d48c09
>     Merge: 18b6e7955d8f d8fbd27469fc
>     Author: David S. Miller <davem@davemloft.net>
>     Date:   Thu Jun 15 14:31:56 2017 -0400
> 
>         Merge branch 'r8152-support-new-chips'
> 
> when the compilation tests happened, but I've reviewed the changes
> coming into net-next in the meantime and didn't see any new usages
> of skb data accessors having come in.

Series applied, thanks!

I tell ya, spatch appears to be the crack cocaine of Linus kernel
development.  Once someone gets into some spatch scripting work,
they can't stop!
