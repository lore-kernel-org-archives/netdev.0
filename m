From: David Miller <davem@davemloft.net>
Subject: Re: [NET_NEXT PATCH 2/2] pkt_action: add new action skbedit
Date: Thu, 28 Aug 2008 01:27:19 -0700 (PDT)
Message-ID: <20080828.012719.114699916.davem@davemloft.net>
References: <20080828011253.7909.5172.stgit@jtkirshe-mobile.jf.intel.com>
	<20080828011257.7909.78529.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38390
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751737AbYH1I1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 04:27:24 -0400
In-Reply-To: <20080828011257.7909.78529.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 27 Aug 2008 18:12:57 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This new action will have the ability to change the priority and/or
> queue_mapping fields on an sk_buff.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

I think you'll need to do range checking on the queue mapping being
set in tcf_skbedit().

qdisc_restart() will accept any skb_queue_mapping() value it
sees in packets obtained via ->dequeue().

