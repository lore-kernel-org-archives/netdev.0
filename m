From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] strip: neighbour table refcount leak
Date: Tue, 29 Aug 2006 21:19:37 -0700 (PDT)
Message-ID: <20060829.211937.92584820.davem@davemloft.net>
References: <20060829145936.64db642c@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linville@tuxdriver.com, netdev@vger.kernel.org,
	cheshire@cs.stanford.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:4524
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964881AbWH3ETj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 00:19:39 -0400
To: shemminger@osdl.org
In-Reply-To: <20060829145936.64db642c@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 29 Aug 2006 14:59:36 -0700

> Found by inspection. The STRIP driver does neigh_lookup() but never releases.
> This driver shouldn't being doing gratuitous arp anyway.
> Untested, obviously, because of lack of hardware.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
