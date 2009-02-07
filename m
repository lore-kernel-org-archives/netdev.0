From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 01/26] igb: optomize/refactor receive path
Date: Sat, 07 Feb 2009 02:46:19 -0800 (PST)
Message-ID: <20090207.024619.235083759.davem@davemloft.net>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42677
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752484AbZBGKqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 05:46:23 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 07 Feb 2009 01:15:04 -0800

> While cleaning up the skb_over panic with small frames I found there was
> room for improvement in the ordering of operations within the rx receive
> flow.  These changes will place the prefetch for the next descriptor to a
> point earlier in the rx path.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

"Optomize"?  Is that something like labotomize? :-)

Anyways, I fixed up that typo and applied all 26 patches
to net-next-2.6

Thanks!
