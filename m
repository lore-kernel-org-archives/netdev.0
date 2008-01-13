From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9] statistics improvements
Date: Sat, 12 Jan 2008 20:55:20 -0800 (PST)
Message-ID: <20080112.205520.55747078.davem@davemloft.net>
References: <20080112064513.803976049@linux-foundation.org>
	<20080112064646.282104074@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@vger.kernel.org,
	stephen.hemminger@vyatta.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34515
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753290AbYAMEzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 23:55:20 -0500
In-Reply-To: <20080112064646.282104074@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 11 Jan 2008 22:45:17 -0800

> Turn the unused size field into a useful counter for the number
> of routes.
> 
> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>

It's not useful if nothing reports it's value.  I'm dropping
this.

Unless you add code to provide this information via procfs
or similar, better to just remove it.
