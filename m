From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 10:10:54 +0400
Message-ID: <20060428061054.GD17360@2ka.mipt.ru>
References: <54AD0F12E08D1541B826BE97C98F99F143B020@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "David S. Miller" <davem@davemloft.net>, kelly@au1.ibm.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:37256 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1030270AbWD1GLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 02:11:45 -0400
To: Caitlin Bestler <caitlinb@broadcom.com>
Content-Disposition: inline
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F143B020@NT-SJCA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 27, 2006 at 02:12:09PM -0700, Caitlin Bestler (caitlinb@broadcom.com) wrote:
> So the real issue is when there is an intelligent device that
> uses hardware packet classification to place the packet in
> the correct ring. We don't want to bypass packet filtering,
> but it would be terribly wasteful to reclassify the packet.
> Intelligent NICs will have packet classification capabilities
> to support RDMA and iSCSI. Those capabilities should be available
> to benefit SOCK_STREAM and SOCK_DGRAM users as well without it
> being a choice of either turning all stack control over to
> the NIC or ignorign all NIC capabilities beyound pretending
> to be a dumb Ethernet NIC.

Btw, how is it supposed to work without header split capabale hardware?

-- 
	Evgeniy Polyakov
