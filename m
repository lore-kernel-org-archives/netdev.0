From: Christoph Raisch <RAISCH@de.ibm.com>
Subject: Re: [PATCH 2/2] ehea: Receive SKB Aggregation
Date: Mon, 4 Jun 2007 14:09:47 +0200
Message-ID: <OF7723C01B.9DD0E9DC-ONC12572F0.0040CA22-C12572F0.0042AC08@de.ibm.com>
References: <20070531134118.GA30501@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Jan-Bernd Themann <themann@de.ibm.com>,
	Jeff Garzik <jeff@garzik.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Stefan Roscher <ossrosch@linux.vnet.ibm.com>,
	ossthema@linux.vnet.ibm.com, Thomas Q Klein <tklein@de.ibm.com>,
	tklein@linux.ibm.com
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:22264 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754498AbXFDMnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 08:43:07 -0400
In-Reply-To: <20070531134118.GA30501@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Christoph Hellwig wrote on 31.05.2007 15:41:18:

> I'm still very unhappy with having all this in various drivers.  There's
> a lot of code that can be turned into generic library functions, and even
> more code that could be made generic with some amount of refactoring.

Yes, we'd also prefer to use a generic function, but we first would want to
get
some "real world" experience how our driver behaves with LRO to be even
able to
define requirements for such a generic function. A lot of this is tied into
pathlengths,
caching, and why does that help compared to a different TCP receive side
processing?
In a perfect world we shouldn't see a diffference if this is enabled or
not,
but measurements indicate something completely different at 10gbit.

Gruss / Regards
Christoph Raisch


