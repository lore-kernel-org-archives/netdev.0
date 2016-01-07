From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v2 net-next 1/5] net: local checksum offload for
 encapsulation
Date: Thu, 7 Jan 2016 17:54:09 +0000
Message-ID: <568EA641.1010906@solarflare.com>
References: <568E9BF9.2050001@solarflare.com>
 <568E9C64.6090305@solarflare.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCBF46D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>,
	"Tom Herbert" <tom@herbertland.com>
To: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:9441 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751920AbcAGRy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 12:54:27 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCBF46D@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/16 17:22, David Laight wrote:
> Isn't it even simpler than that?
> The checksum of the inner packet (including its header) is ~0 (ie 0).
> So the checksum of the whole packet (for the outer header) is the same
> as that of the packet down to the start of the inner header.
Not quite.  The inner pseudo-header is included in the inner checksum
 calculation, but does not actually appear in the packet.  Thus the checksum
 of the inner packet is ~sum_of_inner_pseudo_header.

-ed
