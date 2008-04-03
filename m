From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/13 net-2.6.26] UDP/ICMP/TCP for a namespace v2
Date: Thu, 03 Apr 2008 14:58:34 -0700 (PDT)
Message-ID: <20080403.145834.166621372.davem@davemloft.net>
References: <1206969367.10660.16.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, xemul@openvz.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47172
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755434AbYDCV6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 17:58:33 -0400
In-Reply-To: <1206969367.10660.16.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Mon, 31 Mar 2008 17:16:07 +0400

> This patch set finally enables TCP/UDP and ICMP inside a namespace.
> In order to do this we fix ARP processing, IP options processing and
> allow packets to flow to namespace aware protocols.
> 
> Finally, this makes namespace functional and alive :)
> 
> Changed from v1:
> - inet_csk_ctl_sock_create is renamed to inet_ctl_sock_create. Thanks
>   to Arnaldo Carvalho de Melo <acme@redhat.com and Vlad Yasevich
>   <vladislav.yasevich@hp.com>
> - dccp_ctl_make_reset now accept sock rather than socket. Thanks to
>   Arnaldo Carvalho de Melo <acme@redhat.com>
> - added inet_ctl_sock_destroy
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

All applied and pushed out to net-2.6.26, thanks!

I also made sure to add all of the ACKs from Arnaldo,
as appropriate.
