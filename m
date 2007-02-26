From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6 anycast refcnt fix
Date: Mon, 26 Feb 2007 15:36:43 -0800 (PST)
Message-ID: <20070226.153643.97293021.davem@davemloft.net>
References: <erru08$37g$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xmxwx@asn.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40895
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161401AbXBZXgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 18:36:45 -0500
In-Reply-To: <erru08$37g$1@sea.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Wrobel <xmxwx@asn.pl>
Date: Sun, 25 Feb 2007 13:04:21 +0100

> This patch fixes a bug in Linux IPv6 stack which caused anycast address
> to be added to a device prior DAD has been completed. This led to
> incorrect reference count which resulted in infinite wait for
> unregister_netdevice completion on interface removal.
> 
> Signed-off-by: Michal Wrobel <xmxwx@asn.pl>

Patch applied, thank you.
