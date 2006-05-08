From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]ip_options_fragment() has no effect on fragmentation
Date: Sun, 07 May 2006 22:41:21 -0700 (PDT)
Message-ID: <20060507.224121.38748103.davem@davemloft.net>
References: <1138821701.3852.8.camel@L-tech1>
	<20060202.170840.114568749.davem@davemloft.net>
	<200605051350.03300.weiyj@soft.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28117
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932315AbWEHFlN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 May 2006 01:41:13 -0400
To: weiyj@soft.fujitsu.com
In-Reply-To: <200605051350.03300.weiyj@soft.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: weiyj@soft.fujitsu.com
Date: Fri, 5 May 2006 13:50:02 -0400

> Does this patch will be used? 
> 
> This patch resolved the following problem: When I send IPv4 packet(contain 
> Record Route Option) which need to be fragmented to the router, the router 
> can not fragment it correctly. After fragmented by router, the second 
> fragmentation still contain Record Route Option. Refer to RFC791, Record 
> Route Option must Not be copied on fragmentation, goes in first fragment 
> only.

Actually it didn't get applied for some reason.

Please resubmit it properly with a full changelog and
"Signed-off-by: " lines, and make double sure that your
email client does not corrupt the patch so that I may
apply it cleanly.  Test this by sending it to yourself
and trying to apply the patch.

Thanks.
