From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] Consolidate xxx_frag_intern
Date: Wed, 17 Oct 2007 19:44:42 -0700 (PDT)
Message-ID: <20071017.194442.88473128.davem@davemloft.net>
References: <4714C0AF.1000209@openvz.org>
	<4714C23F.2070008@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35825
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752168AbXJRCon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 22:44:43 -0400
In-Reply-To: <4714C23F.2070008@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 16 Oct 2007 17:53:03 +0400

> This routine checks for the existence of a given entry
> in the hash table and inserts the new one if needed.
> 
> The ->equal callback is used to compare two frag_queue-s
> together, but this one is temporary and will be removed
> later. The netfilter code and the ipv6 one use the same
> routine to compare frags.
> 
> The inet_frag_intern() always returns non-NULL pointer,
> so convert the inet_frag_queue into protocol specific
> one (with the container_of) without any checks.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
