From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: pass kern to net_proto_family create function
Date: Thu, 05 Nov 2009 21:08:00 -0800 (PST)
Message-ID: <20091105.210800.162780369.davem@davemloft.net>
References: <20091104163211.27133.74927.stgit@paris.rdu.redhat.com>
	<20091104163217.27133.6899.stgit@paris.rdu.redhat.com>
	<20091104173147.GG2603@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eparis@redhat.com, netdev@vger.kernel.org, nhorman@redhat.com,
	dwalsh@redhat.com, linux-security-module@vger.kernel.org
To: acme@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52473
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751350AbZKFFHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 00:07:35 -0500
In-Reply-To: <20091104173147.GG2603@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@infradead.org>
Date: Wed, 4 Nov 2009 15:31:47 -0200

> Em Wed, Nov 04, 2009 at 11:32:17AM -0500, Eric Paris escreveu:
>> The generic __sock_create function has a kern argument which allows the
>> security system to make decisions based on if a socket is being created by
>> the kernel or by userspace.  This patch passes that flag to the
>> net_proto_family specific create function, so it can do the same thing.
>> 
>> Signed-off-by: Eric Paris <eparis@redhat.com>
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied to net-next-2.6
