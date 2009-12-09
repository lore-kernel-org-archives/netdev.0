From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] e1000e: only perform ESB2 MDIC workaround on
 certain configurations
Date: Tue, 08 Dec 2009 20:11:05 -0800 (PST)
Message-ID: <20091208.201105.215659668.davem@davemloft.net>
References: <20091208172725.19741.25809.stgit@localhost.localdomain>
	<20091208172819.19741.89888.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37905
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756679AbZLIEK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 23:10:59 -0500
In-Reply-To: <20091208172819.19741.89888.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 08 Dec 2009 09:28:20 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> A workaround added for all ESB2 devices (adds a delay for all MDIC accesses
> which resolves an issue with the MDIC ready bit being set prematurely) is
> applicable only to devices in which the MAC-PHY interconnect is not
> operating in a certain mode with in-band MDIO.  Check the control register
> for the operating mode and enable the workaround accordingly.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
