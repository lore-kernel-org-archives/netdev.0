From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH] multiq: remove root-only requirement from
 multiq_tune
Date: Fri, 12 Sep 2008 15:37:45 -0700 (PDT)
Message-ID: <20080912.153745.184579895.davem@davemloft.net>
References: <20080912223600.6498.54511.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47232
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753614AbYILWhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 18:37:51 -0400
In-Reply-To: <20080912223600.6498.54511.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 12 Sep 2008 15:36:00 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch removes the root-only requirement for the multiq qdisc so that
> you can have prio as a parent if you wish.  This may lead to some odd
> behaviors when parent qdiscs are not multiqueue aware.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Please integrate this into the patch itself, instead of using
a follow-on fixup.

What you're doing just makes for changeset noise.

Thanks.
