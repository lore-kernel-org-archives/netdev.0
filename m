From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next v2 4/5] xen-netback: handle IPv6 TCP GSO
 packets from the guest
Date: Tue, 8 Oct 2013 13:42:05 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD012F306@AMSPEX01CL01.citrite.net>
References: <1381229896-18657-1-git-send-email-paul.durrant@citrix.com>
 <1381229896-18657-5-git-send-email-paul.durrant@citrix.com>
 <20131008133142.GJ28411@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:62634 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751797Ab3JHNmb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 09:42:31 -0400
In-Reply-To: <20131008133142.GJ28411@zion.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Wei Liu [mailto:wei.liu2@citrix.com]
> Sent: 08 October 2013 14:32
> To: Paul Durrant
> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Wei Liu; David Vrabel;
> Ian Campbell
> Subject: Re: [PATCH net-next v2 4/5] xen-netback: handle IPv6 TCP GSO
> packets from the guest
> 
> On Tue, Oct 08, 2013 at 11:58:15AM +0100, Paul Durrant wrote:
> > This patch a xenstore flag, festure-gso-tcpv6, to adevrtise netback can
>             ^ adds            feature               advertise
> 
> > handle IPv6 TCP GSO packets and creates SKB_GSO_TCPV6 skbs if the
> frontend
> > passes an extra segment with the new type XEN_NETIF_GSO_TYPE_TCPV6
> added to
> > netif.h.
> 
> Note the new type should be synced to Xen's netif.h tree with separate
> patch for Xen.
> 

Ok. Do you think it is reasonable to make incremental changes to netif.h in this series and then submit a patch to xen-devel with the complete set once this series is accepted?

  Paul
