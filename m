From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [PATCH 5/6] e1000: Secondary unicast address support
Date: Wed, 14 Nov 2007 01:16:52 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0711140113400.15397@bizon.gios.gov.pl>
References: <20071113231110.13177.27339.stgit@localhost.localdomain>
 <20071113231133.13177.84769.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-12062025-1194999412=:15397"
Cc: davem@davemloft.net, jeff@garzik.org, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:48129 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755374AbXKNARX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 19:17:23 -0500
In-Reply-To: <20071113231133.13177.84769.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-12062025-1194999412=:15397
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Tue, 13 Nov 2007, Auke Kok wrote:

> From: Patrick McHardy <kaber@trash.net>
>
> Add support for configuring secondary unicast addresses. Unicast
> addresses take precendece over multicast addresses when filling
> the exact address filters to avoid going to promiscous mode.
> When more unicast addresses are present than filter slots,
> unicast filtering is disabled and all slots can be used for
> multicast addresses.

Is there any easy way to use it for VRRP? It would be really great to=20
have two IP addresses on the same interface, each with a different hw=20
address.

Best regards,

 =09=09=09=09 Krzysztof Ol=EAdzki
---187430788-12062025-1194999412=:15397--
