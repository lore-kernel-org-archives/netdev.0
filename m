From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000e: swap max hw supported frame size
 between 82574 and 82583
Date: Sun, 04 Oct 2009 21:09:09 -0700 (PDT)
Message-ID: <20091004.210909.219482597.davem@davemloft.net>
References: <20091002223042.4191.43767.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, rjw@sisk.pl,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45055
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751045AbZJEEJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 00:09:15 -0400
In-Reply-To: <20091002223042.4191.43767.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 02 Oct 2009 15:30:42 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> There appears to have been a mixup in the max supported jumbo frame size
> between 82574 and 82583 which ended up disabling jumbo frames on the 82574
> as a result.  This patch swaps the two so that this issue is resolved.
> 
> This patch fixes http://bugzilla.kernel.org/show_bug.cgi?id=14261
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
