From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Consolidate creation of kmem caches with "calculated"
 names
Date: Wed, 17 Oct 2007 21:27:04 -0700 (PDT)
Message-ID: <20071017.212704.34759303.davem@davemloft.net>
References: <4716098A.9000201@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36735
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751315AbXJRE1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 00:27:12 -0400
In-Reply-To: <4716098A.9000201@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 17 Oct 2007 17:09:30 +0400

> Some places in network (like protocol registration and dccp)
> generate the kmem cache name with snprintf() to create caches
> for several protocols with similar names.
> 
> Make the routine that makes this in one place. Possibly, this
> is better to be put in mm/sl[uoa]b.c, but I haven't found
> any other places in kernel that require such functionality,
> so put this code (temporary?) in net/core/util.c
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

I don't think we should be putting kmem_*() interfaces in
a place like net/core/utils.c, please submit that seperately
to the SLAB and/or SLUB maintainers, and once that it in
we can add the uses to the networking.

Tanks.
