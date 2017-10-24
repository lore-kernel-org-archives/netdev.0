From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2017-10-24
Date: Tue, 24 Oct 2017 20:42:03 +0900 (KST)
Message-ID: <20171024.204203.1765906698976153587.davem@davemloft.net>
References: <1508841460-26369-1-git-send-email-steffen.klassert@secunet.com>
        <20171024.201832.1079896012824825450.davem@davemloft.net>
        <20171024113525.GL3323@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59810 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751825AbdJXLmI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 07:42:08 -0400
In-Reply-To: <20171024113525.GL3323@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 24 Oct 2017 13:35:25 +0200

> On Tue, Oct 24, 2017 at 08:18:32PM +0900, David Miller wrote:
>> From: Steffen Klassert <steffen.klassert@secunet.com>
>> Date: Tue, 24 Oct 2017 12:37:38 +0200
>> 
>> > 1) Fix a memleak when we don't find a inner_mode
>> >    during bundle creation. From David Miller.
>> > 
>> > 2) Fix a xfrm policy dump crash. We may crash
>> >    on error when dumping policies via netlink.
>> >    Fix this by initializing the policy walk
>> >    with the cb->start method. This fix is a
>> >    serious stable candidate. From Herbert Xu.
>> > 
>> > Please pull or let me know if there are problems.
>> 
>> Pulled, please submit #2 to -stable indeed!
> 
> I can do so, but whenever I sent something networking related
> to -stable, it was ignored. I think this is because Greg expects
> that you do the stable submissions for networking.

Send it, CC: me, and I'll reply making sure Greg knows.

Thanks.
