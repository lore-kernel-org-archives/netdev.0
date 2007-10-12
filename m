From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Fri, 12 Oct 2007 20:27:24 +0200
Message-ID: <20071012182724.GA12933@one.firstfloor.org>
References: <20071010003716.GB552@one.firstfloor.org> <36D9DB17C6DE9E40B059440DB8D95F5203887DD1@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	shemminger@linux-foundation.org, jeff@garzik.org,
	johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	mcarlson@broadcom.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com, kaber@trash.net
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:41226 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753839AbXJLS1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 14:27:30 -0400
Content-Disposition: inline
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5203887DD1@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> related to this comment, does Linux have a lockless (using atomics)
> singly linked list element?  That would be very useful in a driver hot
> path.

No; it doesn't. At least not a portable one.
Besides they tend to be not faster anyways because e.g. cmpxchg tends
to be as slow as an explicit spinlock.

-Andi

