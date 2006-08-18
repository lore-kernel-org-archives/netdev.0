From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 0/6]:  powerpc/cell spidernet ethernet driver update
Date: Fri, 18 Aug 2006 17:07:00 -0500
Message-ID: <20060818220700.GG26889@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, akpm@osdl.org,
	Arnd Bergmann <arnd@arndb.de>,
	James K Lewis <jklewis@us.ibm.com>,
	Utz Bacher <utz.bacher@de.ibm.com>,
	ens Osterkamp <Jens.Osterkamp@de.ibm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:52879 "EHLO
	e35.co.us.ibm.com") by vger.kernel.org with ESMTP id S1751510AbWHRWHE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 18:07:04 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Jeff,

Can you apply and forward upstream the following series of patches?
This is the same set of patches I sent only a few days ago; however,
it appears that I failed to cc you on some of them, and I failed to
ask anyone in particular to actually apply them. So I'm asking now. :-)

The maintainership of the spidernet driver is transitioning from
Utz Bacher and Jens Osterkamp to Jim Lewis; you should be receiving
a patch to the MAINTAINERS file from Jim, noting this, shortly.  
I suspect that neither Utz nor Jens will be ack'ing or nack'ing 
these patches unless prodded; let me know if you want some particlar
ack from someone before you apply these. (BenH and Arnd Bergmann
are the ones who usually keep us honest about these things.)

Although these are based on a week-old mm tree, they should 
apply cleanly just about anywhere, as there has been little/no 
change to this code base in a long while. 

The patches bring the transmit performance of the driver up
to a decent level, as reviewed in greter detail in the patch
descriptions.

--linas
