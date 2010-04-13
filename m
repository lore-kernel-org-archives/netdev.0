From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] skbuff: remove unused dev_consume_skb
 macro definition
Date: Tue, 13 Apr 2010 02:59:20 -0700 (PDT)
Message-ID: <20100413.025920.129317386.davem@davemloft.net>
References: <20100409200116.31057.29639.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49676
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752412Ab0DMJ7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 05:59:16 -0400
In-Reply-To: <20100409200116.31057.29639.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 09 Apr 2010 13:01:37 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> dev_consume_skb and kfree_skb_clean have no users and in the case of
> kfree_skb_clean could cause potential build issues since I cannot find
> where it is defined.  Based on the patch in which it was introduced it
> appears to have been a bit of leftover code from an earlier version of the
> patch in which kfree_skb_clean was dropped in favor of consume_skb.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
