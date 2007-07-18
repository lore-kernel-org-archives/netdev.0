From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] negative groups in netlink_setsockopt
Date: Wed, 18 Jul 2007 02:08:21 -0700 (PDT)
Message-ID: <20070718.020821.15264737.davem@davemloft.net>
References: <1184675164.3773.83.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51351
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752289AbXGRJIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 05:08:22 -0400
In-Reply-To: <1184675164.3773.83.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 17 Jul 2007 14:26:04 +0200

> Reading netlink_setsockopt it's not immediately clear why there isn't a
> bug when you pass in negative numbers, the reason being that the >=
> comparison is really unsigned although 'val' is signed because
> nlk->ngroups is unsigned. Make 'val' unsigned too.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Applied, but I updated the "(int __user *)" cast in
get_user() to match as well when applying this.

Thanks.
