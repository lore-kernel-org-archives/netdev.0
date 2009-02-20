From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/5] igb: update napi polling to consolidate
 function and return correct values
Date: Fri, 20 Feb 2009 00:23:18 -0800 (PST)
Message-ID: <20090220.002318.13922558.davem@davemloft.net>
References: <20090220043902.29650.35055.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49546
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753533AbZBTIXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 03:23:36 -0500
In-Reply-To: <20090220043902.29650.35055.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Feb 2009 20:39:04 -0800

> igb is currently not returning the correct values for napi.  In addition it
> is doing more work than necessary since it will not exit polling until
> work_done is equal to zero.
> 
> This patch makes the following changes:
> 1.  Consolidates msi-x and non-msi polling routines.
> 2.  Corrects return values for polling routines.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
