From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbe: Disallow SFP 1G modules in the
 SFP+ cages for 82598 and 82599
Date: Mon, 27 Apr 2009 03:16:08 -0700 (PDT)
Message-ID: <20090427.031608.107651846.davem@davemloft.net>
References: <20090423213136.29824.81597.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39876
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752759AbZD0KQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 06:16:15 -0400
In-Reply-To: <20090423213136.29824.81597.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 23 Apr 2009 14:31:37 -0700

> 82598 and 82599 do not support SFP 1G modules.  Instead of allowing the
> driver to load, but never get link, rejecting the module and displaying
> a useful message is more preferrable.  The framework for displaying the
> failure message already exists, now we just need to detect and reject the
> SFP modules.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
