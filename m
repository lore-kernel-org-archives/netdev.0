From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/3] netlink: allocate group bitmaps dynamically
Date: Wed, 18 Jul 2007 15:34:04 -0700 (PDT)
Message-ID: <20070718.153404.00455892.davem@davemloft.net>
References: <20070717122706.899784000@sipsolutions.net>
	<1184769287.4200.1.camel@johannes.berg>
	<469E400C.6030907@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	rui.zhang@intel.com, hadi@cyberus.ca
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34694
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751961AbXGRWeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 18:34:05 -0400
In-Reply-To: <469E400C.6030907@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 18 Jul 2007 18:30:04 +0200

> Johannes Berg wrote:
> > Allow changing the number of groups for a netlink family
> > after it has been created, use RCU to protect the listeners
> > bitmap keeping netlink_has_listeners() lock-free.
> > 
> > Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> > 
> > ---
> > Changes: incorporate Patrick's comments, add kernel-doc
> 
> 
> All three patches look good to me.
> 
> Acked-by: Patrick McHardy <kaber@trash.net>
> 
> and for Jamal again ..
> 
> Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

Aha, Johannes did resubmit all 3 patches, they arrived out
of order here which confused me :-)

I'll apply these, thanks.
