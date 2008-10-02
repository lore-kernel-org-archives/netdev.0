From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 10/16] Don't lookup the socket if there's a
 socket attached to the skb
Date: Thu, 02 Oct 2008 12:58:35 -0700 (PDT)
Message-ID: <20081002.125835.174818312.davem@davemloft.net>
References: <20081001.085104.193726318.davem@davemloft.net>
	<1222962200.14079.19.camel@este>
	<20081002170935.GE17843@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hidden@sch.bme.hu, kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36908
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753829AbYJBT6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 15:58:46 -0400
In-Reply-To: <20081002170935.GE17843@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 2 Oct 2008 14:09:35 -0300

> Why don't you add it to __inet6_lookup, __inet6_lookup and the udp_lib
> lookup routines? And please rename it to skb_steal_sock, as it acts on a
> skb, not on a sock.

That seems to make sense to me.
