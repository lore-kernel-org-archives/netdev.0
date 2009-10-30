From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] e1000e: config PHY via software after
 resets
Date: Thu, 29 Oct 2009 22:54:27 -0700 (PDT)
Message-ID: <20091029.225427.256637745.davem@davemloft.net>
References: <20091029234545.5413.9667.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49112
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755736AbZJ3FyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 01:54:04 -0400
In-Reply-To: <20091029234545.5413.9667.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 29 Oct 2009 16:45:45 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> On PCH-based (82577/82578) and some ICH8-based parts (82566) there is an
> issue with the hardware automatically configuring the PHY with contents
> from the EEPROM after the PHY is reset, so do the configuration by the
> driver instead.  This was already similarly done for some 82566 parts in
> e1000_phy_hw_reset_ich8lan() but needs to be done after other resets,
> so move the PHY configuration code to its own function and call after
> all PHY resets.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
