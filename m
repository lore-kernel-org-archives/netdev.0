From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [RFC 0/3] lro: Generic Large Receive Offload for TCP traffic (IPv6)
Date: Wed, 18 Jul 2007 15:00:59 +0200
Message-ID: <200707181501.00163.ossthema@de.ibm.com>
References: <200707111621.24852.ossthema@de.ibm.com> <20070715091253.GA15790@infradead.org> <20070715.024015.126137834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, netdev@vger.kernel.org, raisch@de.ibm.com,
	themann@de.ibm.com, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, meder@de.ibm.com, tklein@de.ibm.com,
	stefan.roscher@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:31654 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759934AbXGRN2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 09:28:14 -0400
In-Reply-To: <20070715.024015.126137834.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I suggest we keep the interface open for IPv6 support by adding 
an additional parameter but first just get IPv4 support only 
into the kernel. IPv6 support can then incrementially be added.
Would that be ok?



On Sunday 15 July 2007 11:40, David Miller wrote:
> From: Christoph Hellwig <hch@infradead.org>
> Date: Sun, 15 Jul 2007 10:12:53 +0100
> 
> > I'm not sure that's a good idea.  If current chips can't handle ipv6
> > lro there is no way to actually test it and the code will surely bitrot.
> 
> Christoph, you can do LRO pretty much completely in software.
> 
> 
