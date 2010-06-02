From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] enic: bug fix: make the set/get netlink
 VF_PORT support symmetrical
Date: Wed, 02 Jun 2010 02:27:13 -0700 (PDT)
Message-ID: <20100602.022713.85403401.davem@davemloft.net>
References: <20100601185933.4323.2212.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chrisw@redhat.com, netdev@vger.kernel.org
To: scofeldm@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33179
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752625Ab0FBJ1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 05:27:03 -0400
In-Reply-To: <20100601185933.4323.2212.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>
Date: Tue, 01 Jun 2010 11:59:33 -0700

> From: Scott Feldman <scofeldm@cisco.com>
> 
> To make get/set netlink VF_PORT truly symmetrical, we need to keep track
> of what items are set and only return those items on get.  Previously, the
> driver wasn't differentiating between a set of attr with a NULL string,
> for example, and not setting the attr at all.  We only want to return
> the NULL string if the attr was actually set with a NULL string.  Otherwise,
> don't return the attr.
> 
> Signed-off-by: Scott Feldman <scofeldm@cisco.com>

Applied, thanks Scott.
