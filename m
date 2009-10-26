From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/5] e1000e: increase swflag acquisition
 timeout for ICHx/PCH
Date: Mon, 26 Oct 2009 16:17:10 -0700 (PDT)
Message-ID: <20091026.161710.257835809.davem@davemloft.net>
References: <20091026212242.9682.25442.stgit@localhost.localdomain>
	<20091026212306.9682.73519.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49851
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754621AbZJZXQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 19:16:47 -0400
In-Reply-To: <20091026212306.9682.73519.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 26 Oct 2009 14:23:06 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> In some conditions (e.g. when AMT is enabled on the system), it is possible
> to take an extended period of time to for the driver to acquire the sw/fw/hw
> hardware semaphore used to protect against concurrent access of a shared
> resource (e.g. PHY registers).  This could cause PHY registers to not get
> configured properly resulting in link issues.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
