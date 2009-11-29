From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 4/4] ixgbe: Fix Receive Address Register
 (RAR) cleaning and accounting
Date: Sun, 29 Nov 2009 00:34:58 -0800 (PST)
Message-ID: <20091129.003458.78367338.davem@davemloft.net>
References: <20091125045059.23932.10997.stgit@localhost.localdomain>
	<20091125045209.23932.59410.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, shannon.nelson@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37194
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753902AbZK2Iew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 03:34:52 -0500
In-Reply-To: <20091125045209.23932.59410.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 24 Nov 2009 20:52:10 -0800

> From: Shannon Nelson <shannon.nelson@intel.com>
> 
> This fixes an issue when clearing out the RAR entries.  If RAR[0]
> is the only address in use, don't clear the others.
> 
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
