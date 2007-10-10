From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Wed, 10 Oct 2007 11:16:44 +0200
Message-ID: <20071010091644.GA9807@one.firstfloor.org>
References: <1191967006.5324.14.camel@localhost> <20071009.170435.43504422.davem@davemloft.net> <20071010003716.GB552@one.firstfloor.org> <20071009.175025.59469417.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, hadi@cyberus.ca,
	shemminger@linux-foundation.org, jeff@garzik.org,
	johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jagana@us.ibm.com, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:51876 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752990AbXJJJQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 05:16:49 -0400
Content-Disposition: inline
In-Reply-To: <20071009.175025.59469417.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> A 256 entry TX hw queue fills up trivially on 1GB and 10GB, but if you

With TSO really? 

> increase the size much more performance starts to go down due to L2
> cache thrashing.

Another possibility would be to consider using cache avoidance
instructions while updating the TX ring (e.g. write combining 
on x86) 

-Andi

