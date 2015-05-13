From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [RFC PATCH 00/13] Persistent grant maps for xen net
 drivers
Date: Wed, 13 May 2015 11:50:46 +0100
Message-ID: <55532C86.8020409@citrix.com>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<david.vrabel@citrix.com>, <boris.ostrovsky@oracle.com>
To: Joao Martins <joao.martins@neclab.eu>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:21375 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933665AbbEMKux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 06:50:53 -0400
In-Reply-To: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/15 18:18, Joao Martins wrote:
> 
> Packet I/O Tests:
> 
> Measured on a Intel Xeon E5-1650 v2, Xen 4.5, no HT. Used pktgen "burst 1"
> and "clone_skbs 100000" (to avoid alloc skb overheads) with various pkt
> sizes. All tests are DomU <-> Dom0, unless specified otherwise.

Are all these measurements with a single domU with a single VIF?

The biggest problem with a persistent grant method is the amount of
grant table and maptrack resources it requires.  How well does this
scale to 1000s of VIFs?

David
