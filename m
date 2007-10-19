From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Fix race between sk_filter reassign and sk_clone()
Date: Thu, 18 Oct 2007 21:55:21 -0700 (PDT)
Message-ID: <20071018.215521.28810637.davem@davemloft.net>
References: <4715D9D2.8070102@openvz.org>
	<20071017.212302.68039057.davem@davemloft.net>
	<20071019022947.GA29560@lixom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org,
	linux-kernel@vger.kernel.org
To: olof@lixom.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53007
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756136AbXJSEzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 00:55:08 -0400
In-Reply-To: <20071019022947.GA29560@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olof Johansson <olof@lixom.net>
Date: Thu, 18 Oct 2007 21:29:47 -0500

> So, looks like rcu_dereference() returned NULL. I don't know the
> filter code at all, but it seems like it might be a valid case?
> sk_detach_filter() seems to handle a NULL sk_filter, at least.
> 
> 
> So, this needs review by someone who knows the filter, but it fixes the
> problem for me:
> 
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

I've applied this for now to my net-2.6 tree, thanks Olof
for tracking this down.

Pavel please take a look at this and let me know if it should
fixed in some other way.

Thanks!
