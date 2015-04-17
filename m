From: Michael Chan <mchan@broadcom.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Fri, 17 Apr 2015 10:46:09 -0700
Message-ID: <1429292769.6668.7.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <21807.60995.462892.714138@mariner.uk.xensource.com>
	 <1429224694.4720.68.camel@prashant>
	 <21809.13544.303033.990277@mariner.uk.xensource.com>
	 <20150417.131956.2235150293184897656.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <Ian.Jackson@eu.citrix.com>, <prashant@broadcom.com>,
	<cascardo@linux.vnet.ibm.com>, <konrad.wilk@oracle.com>,
	<boris.ostrovsky@oracle.com>, <david.vrabel@citrix.com>,
	<vyasevich@gmail.com>, <xen-devel@lists.xensource.com>,
	<netdev@vger.kernel.org>, <siva.kallam@broadcom.com>,
	<sanjeevb@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:43806 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934084AbbDQRqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 13:46:14 -0400
In-Reply-To: <20150417.131956.2235150293184897656.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-04-17 at 13:19 -0400, David Miller wrote:
> So the gist of the situation is, that NEED_DMA_MAP_STATE can be 'n' in
> situations where we might actually need it to be 'y' based upon kernel
> comman line boot options given.
> 
> Right?

Yes.
> 
> 
