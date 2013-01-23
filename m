From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skb: add a comment to skb_csum_unnecessary to avoid
 miuse
Date: Tue, 22 Jan 2013 20:53:46 -0500 (EST)
Message-ID: <20130122.205346.633138554393148358.davem@davemloft.net>
References: <50FF2F18.1050408@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sanagi.koki@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59278 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752494Ab3AWBxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 20:53:47 -0500
In-Reply-To: <50FF2F18.1050408@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Date: Wed, 23 Jan 2013 09:30:16 +0900

> Due to its name and appearance, someone thinks this only checks if ip_summed is
> CHECKSUM_UNNECESARRY.  But actually, this returns true even if ip_summed is
> CHECKSUM_PARTIAL.  To avoid misuse, this patch a comment which specifies that
> CHECKSUM_PARTIAL is OK.
> 
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>

I'm not applying this, sorry.  It's a one line function and it's not
so non-obvious that it deserves an 8 line comment.
