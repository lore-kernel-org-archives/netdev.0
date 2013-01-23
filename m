From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skb: add a comment to skb_csum_unnecessary to avoid
 miuse
Date: Wed, 23 Jan 2013 00:21:25 -0500 (EST)
Message-ID: <20130123.002125.108247280154857208.davem@davemloft.net>
References: <F6CB40852BC6EF489E0AA83EFF537F470876B9FD@G01JPEXMBYT04>
	<20130122.231353.2100388787067184936.davem@davemloft.net>
	<F6CB40852BC6EF489E0AA83EFF537F470876BBCF@G01JPEXMBYT04>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sanagi.koki@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60934 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768Ab3AWFV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 00:21:26 -0500
In-Reply-To: <F6CB40852BC6EF489E0AA83EFF537F470876BBCF@G01JPEXMBYT04>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Sanagi, Koki" <sanagi.koki@jp.fujitsu.com>
Date: Wed, 23 Jan 2013 05:11:14 +0000

> As for name of the function which confused me, I'm ok now.  But as
> for how to implement, I still think it is inappropriate because of
> the above reason.  So, how about introducing
> CHECKSUM_UNNECESSARY_BIT like below ?

If the user has to look at the implementation, they will see
the "&" and there is no confusion.

Please stop splitting hairs, this is a waste of time.
