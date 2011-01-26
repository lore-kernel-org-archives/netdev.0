From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] tg3: Use new VLAN code
Date: Wed, 26 Jan 2011 13:13:21 -0800 (PST)
Message-ID: <20110126.131321.189691156.davem@davemloft.net>
References: <1296074396-25158-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55132
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753147Ab1AZVMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 16:12:46 -0500
In-Reply-To: <1296074396-25158-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Wed, 26 Jan 2011 12:39:56 -0800

> This patch pivots the tg3 driver to the new VLAN infrastructure.
> All references to vlgrp have been removed.  The driver still attempts to
> disable VLAN tag stripping if CONFIG_VLAN_8021Q or
> CONFIG_VLAN_8021Q_MODULE is not defined.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Reviewed-by: Michael Chan <mchan@broadcom.com>

Applied, thanks for doing this backport.
