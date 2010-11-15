From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] 8021q: set hard_header_len when VLAN
 offload features are toggled
Date: Mon, 15 Nov 2010 10:11:59 -0800 (PST)
Message-ID: <20101115.101159.28810061.davem@davemloft.net>
References: <20101031002232.8691.41201.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46379
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756654Ab0KOSLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 13:11:34 -0500
In-Reply-To: <20101031002232.8691.41201.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Sat, 30 Oct 2010 17:22:32 -0700

> Toggling the vlan tx|rx hw offloads needs to set the hard_header_len
> as well otherwise we end up using LL_RESERVED_SPACE incorrectly.
> This results in pskb_expand_head() being used unnecessarily.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
