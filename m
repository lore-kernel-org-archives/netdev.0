From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH 2/4] xen-netfront: drop skb when skb->len >
 65535
Date: Thu, 21 Mar 2013 14:20:13 +0000
Message-ID: <1363875613.2160.17.camel@zion.uk.xensource.com>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
	 <1363602955-24790-3-git-send-email-wei.liu2@citrix.com>
	 <51471AAC.2050509@citrix.com>
	 <1363614500.30193.47.camel@zakaz.uk.xensource.com>
	 <51471DE0.9060506@citrix.com> <514A15C8.1050209@citrix.com>
	 <1363873208.2160.13.camel@zion.uk.xensource.com>
	 <514B151A.80705@citrix.com>
	 <1363875350.2160.16.camel@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:31495 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932227Ab3CUOUP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Mar 2013 10:20:15 -0400
In-Reply-To: <1363875350.2160.16.camel@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-21 at 14:15 +0000, Wei Liu wrote:
> On Thu, 2013-03-21 at 14:11 +0000, David Vrabel wrote:
> > On 21/03/13 13:40, Wei Liu wrote:
> > > 
> > > 
> > > I think the correct action is to just take first txp and loop responding
> > > until we consume the whole packet.
> > 
> > Um.  This is what the patch is doing.
> > 
> 
> No. The idx you passed in is the index of the first txp, and idx + fras
> doesn't necessary point to last tx requests of the packet. We should use
> XEN_NETTXF_more_data to loop through the packet.
> 

Sorry for the noise, this patch already loop through the whole packet.


Wei.

> 
> Wei.
> 
> > David
> 
> 
