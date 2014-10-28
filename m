From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] udp: Reset flow table for flows over
 unconnected sockets
Date: Tue, 28 Oct 2014 00:51:21 -0400 (EDT)
Message-ID: <20141028.005121.1715627351754245965.davem@davemloft.net>
References: <CA+mtBx_V3WT1bbXY9F731GNdDdb3+ebHwj9hRyVEFynAPYhSXg@mail.gmail.com>
	<1414451970.2922.27.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx_eQKOkM-0PEXG2WEMosXDtqHgwT3j7NnQpP62KdZeJKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53834 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151AbaJ1EvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 00:51:23 -0400
In-Reply-To: <CA+mtBx_eQKOkM-0PEXG2WEMosXDtqHgwT3j7NnQpP62KdZeJKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 27 Oct 2014 18:09:25 -0700

> This indicates nothing about the merits of this patch. Nevertheless,
> in order to avoid further rat-holing and since this patch does change
> a long standing behavior I'll will respin to make it enabled only by
> sysctl.

Kind of disappointed on my end that you haven't addressed Eric's
main point, which is that:

1) A hash table shared between protocols will perform poorly for
   mixed workloads which are becomming increasingly common.

2) UDP is fundamentally different from TCP in that the issue of
   'flow' vs. 'non-flow' packets

I personally do not see you avoiding this conversation by simply
hiding the new behavior behind a sysctl, I still want you to address
it before I apply anything.
