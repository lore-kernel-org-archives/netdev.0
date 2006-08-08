From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC][PATCH 8/9] 3c59x driver conversion
Date: Tue, 08 Aug 2006 19:07:10 -0400
Message-ID: <44D9191E.7080203@garzik.org>
References: <20060808193325.1396.58813.sendpatchset@lappy> <20060808193447.1396.59301.sendpatchset@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Daniel Phillips <phillips@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45967 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932237AbWHHXHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 19:07:14 -0400
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060808193447.1396.59301.sendpatchset@lappy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Zijlstra wrote:
> Update the driver to make use of the netdev_alloc_skb() API and the
> NETIF_F_MEMALLOC feature.

NETIF_F_MEMALLOC does not exist in the upstream tree...  nor should it, IMO.

netdev_alloc_skb() is in the tree, and that's fine.

	Jeff



