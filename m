From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] net: Add napi_sycnhronize() to sync with napi poll
Date: Thu, 18 Oct 2007 11:26:22 +1000
Message-ID: <1192670782.12879.7.camel@pasglop>
References: <1192513792.19073.23.camel@pasglop>
	 <20071016115318.0fc36af3@freepuppy.rosehill>
	 <1192589522.11899.130.camel@pasglop> <47157EA4.1000500@garzik.org>
	 <1192591481.11899.134.camel@pasglop>
	 <20071017083107.6a1b1bd3@freepuppy.rosehill>
	 <1192658654.6783.43.camel@pasglop>
	 <1192669323.13993.33.camel@localhost.localdomain>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41537 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752863AbXJRB1d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 21:27:33 -0400
In-Reply-To: <1192669323.13993.33.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 2007-10-17 at 20:02 -0500, Josh Boyer wrote:
> k, trying again, leaving the actual patch below.  In the above patch
> description, you still call it __napi_synchronize.  In the patch
> below,
> it's napi_syncronize.
> 
> I was just trying to point out to whomever commits this patch that the
> actual description should probably be fixed.

Yup, I noticed finally :-) I think whoever commits can fix it up (it's
likely that it's sch patch that gets commited anyway).

Ben.


