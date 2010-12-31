From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v2 0/4] dcbnl: Extending dcbnl to support
 non-host DCBX
Date: Fri, 31 Dec 2010 10:52:53 -0800 (PST)
Message-ID: <20101231.105253.112601766.davem@davemloft.net>
References: <1293726402.29378.91.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, john.r.fastabend@intel.com,
	lucy.liu@intel.com, netdev@vger.kernel.org
To: shmulikr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34201
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751622Ab0LaSwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 13:52:23 -0500
In-Reply-To: <1293726402.29378.91.camel@lb-tlvb-shmulik.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Shmulik Ravid" <shmulikr@broadcom.com>
Date: Thu, 30 Dec 2010 18:26:42 +0200

> DCBX is the exchange protocol for negotiating DCB parameters between a
> host and a switch. In some circumstances the DCBX negotiator can not
> reside in the host directly on top of the networking interface. For
> instance many converged network adapters support an embedded DCBX engine
> that performs the negotiation and configures the device with the
> negotiated parameters. Another example is virtual hosts and SRIOV
> virtual functions.
> 
> The following patches extend the dcbnl netlink interface so in addition
> to its current semantics it offers a standard mechanism for managing
> such non-host DCBX engines. In this new mode 'set' operations are used
> to set the initial negotiation configuration and the 'get' operation are
> used to retrieve the negotiated results. 

All applied, thanks.
