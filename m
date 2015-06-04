From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next 00/13] mlx5: Add Interface Step Sequence ID
 support
Date: Thu, 04 Jun 2015 16:41:34 -0700 (PDT)
Message-ID: <20150604.164134.807623693924296830.davem@redhat.com>
References: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, majd@mellanox.com, hagaya@mellanox.com,
	talal@mellanox.com, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44547 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752508AbbFDXlg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 19:41:36 -0400
In-Reply-To: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu,  4 Jun 2015 19:30:35 +0300

> ISSI (Interface Step Sequence ID) defines the step sequence ID of the 
> interface between the driver to the firmware and is incremented by 
> steps of one. ISSI is used to enable deprecating/modifying features, 
> command interfaces and such, while maintaining compatibility.
> 
> As the driver serves both ConnectIB (CIB) and ConnectX4, we carefully 
> made sure that the IB functionality keeps running also on older CIB 
> firmware releases that don't support ISSI. 
> 
> The Ethernet functionailty is available only on ConnectX4 where all 
> firmware releases support the feature since the very basic ISSI level. 
> So at this point no need for compatility code there.
> 
> As done prior to this series, when the Ethernet functionlity is enabled, 
> during the initialization flow, the core driver performs a query of the 
> supported ISSIs using the QUERY_ISSI command, and then, if ISSI is supported, 
> sets the actual issi value informing the firmware on which ISSI level to run, 
> using SET_ISSI command.
> 
> Previously, the IB driver wasn't ready to work on that mode, and hence
> building both the IB driver and the Ethernet functionality in the core
> driver were disallowed by Kconfigs, with this series, we allow users to
> enable them both.

Series applied, thanks.
