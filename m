From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next v3 1/9] xen-netback: Introduce TX
 grant map definitions
Date: Thu, 9 Jan 2014 18:23:25 +0000
Message-ID: <52CEE91D.50105@citrix.com>
References: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com> <1389139818-24458-2-git-send-email-zoltan.kiss@citrix.com> <20140109153010.GE12164@zion.uk.xensource.com> <52CEC370.10503@citrix.com> <alpine.DEB.2.02.1401091722150.21510@kaball.uk.xensource.com> <52CEE084.5000409@citrix.com> <alpine.DEB.2.02.1401091759100.21510@kaball.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, <jonathan.davies@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	=?ISO-8859-1?Q?Roger_Pau_Monn=E9?= <roger.pau@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:56231 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756126AbaAISXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 13:23:55 -0500
In-Reply-To: <alpine.DEB.2.02.1401091759100.21510@kaball.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/14 18:09, Stefano Stabellini wrote:
> 
> I agree, but I think that we have different views on the use case.
> To me the m2p_override use case is "everywhere an mfn_to_pfn translation
> is required", that unfortunately is potentially everywhere at this time.

mfn_to_pfn() cannot be made to work correctly with foreign MFNs.  It's a
fundamentally unsolvable problem.

IMO, the only sensible use of the m2p_override is to cause mfn_to_pfn()
to BUG() if a foreign MFN is used.

David
