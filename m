From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 01/16] Loosen source address check on IPv4
 output
Date: Wed, 01 Oct 2008 07:28:56 -0700 (PDT)
Message-ID: <20081001.072856.11593975.davem@davemloft.net>
References: <20081001142431.4893.48078.stgit@este>
	<20081001142431.4893.61466.stgit@este>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: hidden@sch.bme.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52078
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751537AbYJAO3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 10:29:08 -0400
In-Reply-To: <20081001142431.4893.61466.stgit@este>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: KOVACS Krisztian <hidden@sch.bme.hu>
Date: Wed, 01 Oct 2008 16:24:31 +0200

> ip_route_output() contains a check to make sure that no flows with
> non-local source IP addresses are routed. This obviously makes using
> such addresses impossible.
> 
> This patch introduces a flowi flag which makes omitting this check
> possible. The new flag provides a way of handling transparent and
> non-transparent connections differently.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>

Applied to net-next-2.6
