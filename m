From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 1/3] netlink: allocate group bitmaps dynamically
Date: Wed, 18 Jul 2007 18:30:04 +0200
Message-ID: <469E400C.6030907@trash.net>
References: <20070717122706.899784000@sipsolutions.net> <1184769287.4200.1.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Zhang Rui <rui.zhang@intel.com>, jamal <hadi@cyberus.ca>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42643 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933421AbXGRQaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 12:30:35 -0400
In-Reply-To: <1184769287.4200.1.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> Allow changing the number of groups for a netlink family
> after it has been created, use RCU to protect the listeners
> bitmap keeping netlink_has_listeners() lock-free.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> 
> ---
> Changes: incorporate Patrick's comments, add kernel-doc


All three patches look good to me.

Acked-by: Patrick McHardy <kaber@trash.net>

and for Jamal again ..

Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>
