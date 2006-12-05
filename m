From: Muli Ben-Yehuda <muli@il.ibm.com>
Subject: Re: network devices don't handle pci_dma_mapping_error()'s
Date: Tue, 5 Dec 2006 09:00:45 +0200
Message-ID: <20061205070045.GE3619@rhun.ibm.com>
References: <200612011340.kB1DeEhR014690@dut39.unminc.com> <45711007.5030704@garzik.org> <20061204103949.3d05b1ff@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	"Amit S. Kale" <amitkale@netxen.com>, netdev@vger.kernel.org,
	brazilnut@us.ibm.com, netxenproj@linsyssoft.com, rob@netxen.com,
	romieu@fr.zoreil.com, sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:47072 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937462AbWLEHAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 02:00:48 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id kB570lj2231238
	for <netdev@vger.kernel.org>; Tue, 5 Dec 2006 07:00:47 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB570l5R2547828
	for <netdev@vger.kernel.org>; Tue, 5 Dec 2006 08:00:47 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB570ki1010674
	for <netdev@vger.kernel.org>; Tue, 5 Dec 2006 08:00:47 +0100
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061204103949.3d05b1ff@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 04, 2006 at 10:39:49AM -0800, Stephen Hemminger wrote:

> I notice that no current network driver handles dma mapping errors.
> Might that be part of the problem.  On i386, this never happens, and
> it would be rare on most others.

IOMMUs are already available on x86-64 and are going to get widespread
with the the introduction of IOMMUs from Intel and AMD. Might as well
fix it now...

How about CONFIG_DEBUG_DMA_API that does book-keeping and yells if a
driver is mis-using the DMA API?

Cheers,
Muli
