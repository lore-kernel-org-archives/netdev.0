From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2 4/5] xen-netback: handle IPv6 TCP GSO packets
 from the guest
Date: Tue, 8 Oct 2013 14:31:42 +0100
Message-ID: <20131008133142.GJ28411@zion.uk.xensource.com>
References: <1381229896-18657-1-git-send-email-paul.durrant@citrix.com>
 <1381229896-18657-5-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:44238 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754488Ab3JHNbn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Oct 2013 09:31:43 -0400
Content-Disposition: inline
In-Reply-To: <1381229896-18657-5-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 08, 2013 at 11:58:15AM +0100, Paul Durrant wrote:
> This patch a xenstore flag, festure-gso-tcpv6, to adevrtise netback can
            ^ adds            feature               advertise

> handle IPv6 TCP GSO packets and creates SKB_GSO_TCPV6 skbs if the frontend
> passes an extra segment with the new type XEN_NETIF_GSO_TYPE_TCPV6 added to
> netif.h.

Note the new type should be synced to Xen's netif.h tree with separate
patch for Xen.

Wei.
