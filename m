From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: [SCTP]: Fix a race between module load and protosw
 access
Date: Thu, 20 Mar 2008 15:18:54 -0700 (PDT)
Message-ID: <20080320.151854.41734345.davem@davemloft.net>
References: <47E2670C.1040900@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55558
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757517AbYCTWSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 18:18:37 -0400
In-Reply-To: <47E2670C.1040900@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 20 Mar 2008 09:30:52 -0400

> There is a race is SCTP between the loading of the module
> and the access by the socket layer to the protocol functions.
> In particular, a list of addresss that SCTP maintains is
> not initialized prior to the registration with the protosw.
> Thus it is possible for a user application to gain access
> to SCTP functions before everything has been initialized.
> The problem shows up as odd crashes during connection
> initializtion when we try to access the SCTP address list.
> 
> The solution is to refactor how we do registration and
> initialize the lists prior to registering with the protosw.
> Care must be taken since the address list initialization
> depends on some other pieces of SCTP initialization.  Also
> the clean-up in case of failure now also needs to be refactored.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Acked-by: Sridhar Samudrala <sri@us.ibm.com>

Looks good, applied, thanks Vlad.
