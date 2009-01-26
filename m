From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000e: workaround hw errata
Date: Mon, 26 Jan 2009 12:16:47 -0800 (PST)
Message-ID: <20090126.121647.41760330.davem@davemloft.net>
References: <20090124013527.2832.92374.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41943
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753354AbZAZUQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 15:16:44 -0500
In-Reply-To: <20090124013527.2832.92374.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 23 Jan 2009 17:35:31 -0800

> There is a hardware errata in some revisions of the 82574 that needs
> to be worked around in the driver by setting a register bit at init.
> 
> If this bit is not set A0 versions of the 82574 can generate
> tx hangs.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks Jeff.
