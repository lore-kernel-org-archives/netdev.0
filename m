From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: drop capability from protocol definitions
Date: Thu, 05 Nov 2009 21:07:58 -0800 (PST)
Message-ID: <20091105.210758.191587916.davem@davemloft.net>
References: <20091104163211.27133.74927.stgit@paris.rdu.redhat.com>
	<20091104173104.GF2603@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eparis@redhat.com, netdev@vger.kernel.org, nhorman@redhat.com,
	dwalsh@redhat.com, linux-security-module@vger.kernel.org
To: acme@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52468
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750805AbZKFFHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 00:07:33 -0500
In-Reply-To: <20091104173104.GF2603@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@infradead.org>
Date: Wed, 4 Nov 2009 15:31:04 -0200

> Em Wed, Nov 04, 2009 at 11:32:11AM -0500, Eric Paris escreveu:
>> struct can_proto had a capability field which wasn't ever used.  It is dropped
>> entirely.
>> 
>> struct inet_protosw had a capability field which can be more clearly expressed
>> in the code by just checking if sock->type = SOCK_RAW.
>> 
>> Signed-off-by: Eric Paris <eparis@redhat.com>
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied to net-next-2.6
