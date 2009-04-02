From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] igb: set num_rx/tx_queues to 0 when queues are
 freed
Date: Thu, 02 Apr 2009 00:59:55 -0700 (PDT)
Message-ID: <20090402.005955.238686335.davem@davemloft.net>
References: <20090401063759.3046.89960.stgit@lost.foo-projects.org>
	<20090401063819.3046.60000.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41756
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752393AbZDBIAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:00:07 -0400
In-Reply-To: <20090401063819.3046.60000.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 31 Mar 2009 23:38:19 -0700

> An issue was seen on suspend in which the system reported a page fault.  This
> was due to the new reg_idx code being called after the queues were freed.
> 
> This update prevents any for loops from going through the queues by setting
> the number of queues to 0 when they are freed.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
