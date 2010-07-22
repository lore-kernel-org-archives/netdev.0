From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: macvtap: Limit packet queue length
Date: Thu, 22 Jul 2010 09:05:26 -0700
Message-ID: <1279814726.3211.5.camel@localhost.localdomain>
References: <20100722064157.GA25913@gondor.apana.org.au>
	 <20100722074431.GA26744@gondor.apana.org.au>
	 <201007221130.53612.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mark Wagner <mwagner@redhat.com>,
	Chris Wright <chrisw@sous-sol.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:50282 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753155Ab0GVQGx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jul 2010 12:06:53 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6MG4kG4028605
	for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 12:04:46 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6MG6ptj353270
	for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 12:06:51 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6MG5c5H026382
	for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 10:05:39 -0600
In-Reply-To: <201007221130.53612.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-07-22 at 11:30 +0200, Arnd Bergmann wrote:
> In the TX direction, we really don't queue, since we simply forward
> to the lowerdev tx queue, so exposing the tunable to user space
> as the tx queue length is a little bit awkward, as well as
> inconsistent
> between macvtap and macvlan.

Maybe we can use lowerdev backlog queue size here from receiving path
here?

thanks
Shirley

