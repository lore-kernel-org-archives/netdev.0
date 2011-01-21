From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] cxgb4: fix reported state of interfaces
 without link
Date: Thu, 20 Jan 2011 17:00:50 -0800 (PST)
Message-ID: <20110120.170050.215541105.davem@davemloft.net>
References: <1295486945-22015-1-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60601
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753196Ab1AUBAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 20:00:16 -0500
In-Reply-To: <1295486945-22015-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Wed, 19 Jan 2011 17:29:05 -0800

> Currently tools like ip and ifconfig report incorrect state for cxgb4
> interfaces that are up but do not have link and do so until first link
> establishment.  This is because the initial netif_carrier_off call is
> before register_netdev and it needs to be after to be fully effective.
> Fix this by moving netif_carrier_off into .ndo_open.
> 
> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>

Applied.
