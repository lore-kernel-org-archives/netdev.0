From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] igb: Do not overwrite mdicnfg
 register when accessing 82580 phy
Date: Mon, 22 Mar 2010 18:30:37 -0700 (PDT)
Message-ID: <20100322.183037.128602875.davem@davemloft.net>
References: <20100323000724.19939.17642.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59904
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756380Ab0CWBaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 21:30:14 -0400
In-Reply-To: <20100323000724.19939.17642.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 22 Mar 2010 17:07:26 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change removes the extra configuration we were doing on the mdicnfg
> register which should be set by EEPROM and which we should not need to
> write again afterwards.  This code was a holdover from some earlier
> development work that was being done on a board with an incomplete EEPROM
> and is no longer needed now that the production EEPROMs are in place.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
