From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: macvtap: Limit packet queue length
Date: Thu, 22 Jul 2010 11:42:47 -0700
Message-ID: <1279824167.3211.7.camel@localhost.localdomain>
References: <20100722064157.GA25913@gondor.apana.org.au>
	 <20100722074431.GA26744@gondor.apana.org.au>
	 <201007221130.53612.arnd@arndb.de>
	 <1279814726.3211.5.camel@localhost.localdomain>
	 <20100722160859.GB30723@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mark Wagner <mwagner@redhat.com>,
	Chris Wright <chrisw@sous-sol.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:35114 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751772Ab0GVSmx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jul 2010 14:42:53 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6MIU5o2000853
	for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 14:30:05 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6MIgo71410814
	for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 14:42:50 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6MIgnKT010016
	for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 14:42:49 -0400
In-Reply-To: <20100722160859.GB30723@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Then it's better to add some comments here to indicate macvtap
tx_queue_len actually controls sk_receive_queue in receiving path.

Thanks
Shirley

