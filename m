From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Wild and crazy ideas involving struct sk_buff
Date: Wed, 22 Aug 2007 14:08:05 -0700 (PDT)
Message-ID: <20070822.140805.54950393.davem@davemloft.net>
References: <200708221631.34234.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmorris@namei.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43606
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764207AbXHVVII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 17:08:08 -0400
In-Reply-To: <200708221631.34234.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>
Date: Wed, 22 Aug 2007 16:31:34 -0400

> We're currently talking about several different ideas to solve the problem, 
> including leveraging the sk_buff.secmark field, and one of the ideas was to 
> add an additional field to the sk_buff structure.  Knowing how well that idea 
> would go over (lead balloon is probably an understatement at best) I started 
> looking at what I might be able to remove from the sk_buff struct to make 
> room for a new field (the new field would be a u32).  Looking at the sk_buff 
> structure it appears that the sk_buff.dev and sk_buff.iif fields are a bit 
> redundant and removing the sk_buff.dev field could free 32/64 bits depending 
> on the platform.  Is there any reason (performance?) for keeping the 
> sk_buff.dev field around?  Would the community be open to patches which 
> removed it and transition users over to the sk_buff.iif field?  Finally, 
> assuming the sk_buff.dev field was removed, would the community be open to 
> adding a new LSM/SELinux related u32 field to the sk_buff struct?

It's there for performance, and I bet there might be some semantic
issues involved.

And ironically James Morris still owes me a struct sk_buff removal
from when I let him put the "secmark" thing in there!

Stop spending money you guys haven't earned yet :-)
