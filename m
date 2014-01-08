From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: xfrm: xfrm_policy: fix inline not at
 beginning of declaration
Date: Wed, 08 Jan 2014 00:57:53 -0500 (EST)
Message-ID: <20140108.005753.803063221953593992.davem@davemloft.net>
References: <1389133227-11086-1-git-send-email-dborkman@redhat.com>
	<20140107.183412.1584306758322996233.davem@davemloft.net>
	<20140108055536.GX31491@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbaAHF5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 00:57:55 -0500
In-Reply-To: <20140108055536.GX31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 8 Jan 2014 06:55:36 +0100

> On Tue, Jan 07, 2014 at 06:34:12PM -0500, David Miller wrote:
>> From: Daniel Borkmann <dborkman@redhat.com>
>> Date: Tue,  7 Jan 2014 23:20:27 +0100
>> 
>> > Fix three warnings related to:
>> > 
>> >   net/xfrm/xfrm_policy.c:1644:1: warning: 'inline' is not at beginning of declaration [-Wold-style-declaration]
>> >   net/xfrm/xfrm_policy.c:1656:1: warning: 'inline' is not at beginning of declaration [-Wold-style-declaration]
>> >   net/xfrm/xfrm_policy.c:1668:1: warning: 'inline' is not at beginning of declaration [-Wold-style-declaration]
>> > 
>> > Just removing the inline keyword is sufficient as the compiler will
>> > decide on its own about inlining or not.
>> > 
>> > Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> 
>> Applied.
> 
> I have a fix for this warnings in the ipsec-next tree too:
> 
> commit 2f3ea9a95c58fd0e4bed18a9c9dfe53739fee3b2
> Author: Weilong Chen <chenweilong@huawei.com>
> Date:   Tue Dec 24 09:43:50 2013 +0800
> 
>     xfrm: checkpatch erros with inline keyword position
>     
>     Signed-off-by: Weilong Chen <chenweilong@huawei.com>
>     Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> 
> 
> Should I revert it, or do you want to solve the conflict when
> I send the ipsec-next pull request?

Just leave it alone, I'll take care of it at the next merge.
