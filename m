From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] gianfar: fix undo of reserve()
Date: Wed, 24 Mar 2010 11:47:59 -0700 (PDT)
Message-ID: <20100324.114759.200629461.davem@davemloft.net>
References: <A6A1774AFD79E346AE6D49A33CB294530DC19FC4@EX-BE-017-SFO.shared.themessagecenter.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ben@bigfootnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53296
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932768Ab0CXSrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 14:47:36 -0400
In-Reply-To: <A6A1774AFD79E346AE6D49A33CB294530DC19FC4@EX-BE-017-SFO.shared.themessagecenter.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ben Menchaca (ben@bigfootnetworks.com)" <ben@bigfootnetworks.com>
Date: Wed, 24 Mar 2010 08:05:02 -0700

> From: Ben Menchaca <ben@bigfootnetworks.com>
> 
> Fix undo of reserve() before RX recycle
> 
> gfar_new_skb reserve()s space in the SKB to align it.  If an error occurs,
> and the skb needs to be returned to the RX recycle queue, the current code
> attempts to reset head, but did not reset tail.  This patch remembers the
> alignment amount, and reverses the reserve() when needed.
> 
> Signed-off-by: Ben Menchaca <ben@bigfootnetworks.com>

So, is this tested at least a little bit?
