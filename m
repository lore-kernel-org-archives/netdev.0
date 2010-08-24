From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [PATCH net-next-2.6] bna: fix stats handling
Date: Tue, 24 Aug 2010 13:48:26 -0700
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86A4AE225DD0@HQ1-EXCH01.corp.brocade.com>
References: <20100823.203552.63040549.davem@davemloft.net>
	<1282627901.2378.1451.camel@edumazet-laptop>
	<E5313AF6F2BFD14293E5FD0F94750F86A4AE225D69@HQ1-EXCH01.corp.brocade.com>
 <20100824.123645.39174077.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Akshay Mathur <amathur@brocade.com>,
	Debashis Dutt <ddutt@Brocade.COM>,
	Jing Huang <huangj@Brocade.COM>
To: David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:55054 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755968Ab0HXUtX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 16:49:23 -0400
In-Reply-To: <20100824.123645.39174077.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric, David,

It was a mistake, I think it was a false alarm due to an email client issue. The patch was applied to net-next-2.6 and it went through cleanly. We are testing the patch and the fixes. We will let you know the results soon.

>diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c index 491d148..a935b96 100644
>--- a/drivers/net/bna/bnad.c
>+++ b/drivers/net/bna/bnad.c
>@@ -1964,25 +1964,24 @@ bnad_enable_default_bcast(struct bnad *bnad)
> 
> /* Statistics utilities */
> void
>-bnad_netdev_qstats_fill(struct bnad *bnad)
>+bnad_netdev_qstats_fill(struct bnad *bnad, struct rtnl_link_stats64 
>+*stats)

It looks like the email client split the line and also added a + sign, giving an illusion of insertion which was not actually there.

Thanks,
Rasesh

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Tuesday, August 24, 2010 12:37 PM
To: Rasesh Mody
Cc: eric.dumazet@gmail.com; netdev@vger.kernel.org; Akshay Mathur; Debashis Dutt; Jing Huang
Subject: Re: [PATCH net-next-2.6] bna: fix stats handling

From: Rasesh Mody <rmody@brocade.com>
Date: Tue, 24 Aug 2010 11:49:45 -0700

> We tried applying the patch to the source, it looks corrupted. Can
> you please resubmit the patch?

His patch applies absolutely cleanly to net-next-2.6

I had to make fixes to your driver, as I mentioned when I checked
in your patch yesterday, so you absolutely must test against
what I added to net-next-2.6 and not what you have locally in
your trees.
