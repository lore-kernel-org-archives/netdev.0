From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: Add napi_sycnhronize() to sync with napi poll
Date: Wed, 17 Oct 2007 18:36:23 -0500
Message-ID: <1192664183.13993.30.camel@localhost.localdomain>
References: <1192513792.19073.23.camel@pasglop>
	 <20071016115318.0fc36af3@freepuppy.rosehill>
	 <1192589522.11899.130.camel@pasglop> <47157EA4.1000500@garzik.org>
	 <1192591481.11899.134.camel@pasglop>
	 <20071017083107.6a1b1bd3@freepuppy.rosehill>
	 <1192658654.6783.43.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:37204 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757376AbXJQXuH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 19:50:07 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9HNo29O012658
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 19:50:02 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9HNo29P056990
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 19:50:02 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9HNnpKa006929
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 19:49:52 -0400
In-Reply-To: <1192658654.6783.43.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-10-18 at 08:04 +1000, Benjamin Herrenschmidt wrote:
> net: Add __napi_synchronize() to sync with napi poll
> 
> The EMAC driver which needs to handle multiple devices with one
> NAPI instance implements its own per-channel disable bit. However,
> when setting such a bit, it needs to synchronize with the poller
> (that is make sure that any pending poller instance has completed,
> or is started late enough to see that disable bit).
> 
> This implements a low level __napi_synchronize() function to acheive
> that. The underscores are to emphasis the low level aspect of it and
> to discourage driver writers who don't know what they are doing to
> use it (to please DaveM :-)

Erm.. your commit log calls it __napi_synchronize still.

josh

