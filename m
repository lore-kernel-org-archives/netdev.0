From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net:cpsw: Pass unhandled ioctl's on to generic phy ioctl
Date: Wed, 5 Feb 2014 13:48:43 +0530
Message-ID: <52F1F3E3.2050906@ti.com>
References: <1391500242-10554-1-git-send-email-stefan.sorensen@spectralink.com>	 <1391511050.3003.21.camel@deadeye.wl.decadent.org.uk>	 <1391526492.7871.8.camel@e37108.spectralink.com>	 <1391550719.3003.33.camel@deadeye.wl.decadent.org.uk> <1391585274.7871.19.camel@e37108.spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?B?IlPDuHJlbnNlbiwgU3RlZmFuIg==?=
	<Stefan.Sorensen@spectralink.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:45780 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751352AbaBEITO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Feb 2014 03:19:14 -0500
In-Reply-To: <1391585274.7871.19.camel@e37108.spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 05 February 2014 12:58 PM, S=C3=B8rensen, Stefan wrote:
> The CPSW only supports timestamping which is only one part of the PTP
> functionality. Some PHYs (like the dp83630 that we use with the CPSW)
> also has external event generation and detection.
CPSW also has External event detection upto 4 events and newer SoCs upt=
o
8 events, currently no boards came with this pins pinned out, so it is
not supported as of now. If we have a board design with this we can
support external event generation.

Regards
Mugunthan V N
