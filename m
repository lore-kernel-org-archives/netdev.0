From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/5] e1000e: clear PHY wakeup bit after LCD
 reset on 82577/82578
Date: Mon, 26 Oct 2009 16:17:04 -0700 (PDT)
Message-ID: <20091026.161704.19905648.davem@davemloft.net>
References: <20091026212242.9682.25442.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49848
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754435AbZJZXQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 19:16:41 -0400
In-Reply-To: <20091026212242.9682.25442.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 26 Oct 2009 14:22:47 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Performing a dummy read of the PHY Wakeup Control (WUC) register clears the
> wakeup enable bit set by an PHY reset.  If this bit remains set, link
> problems may occur.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
