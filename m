From: David Miller <davem@davemloft.net>
Subject: Re: Oops in tcp_output.c, kernel 2.6.38-rc3
Date: Mon, 07 Feb 2011 13:02:34 -0800 (PST)
Message-ID: <20110207.130234.112590109.davem@davemloft.net>
References: <20110204153254.5c37c6f2@katamari>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: cebbert@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38111
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754524Ab1BGVB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 16:01:58 -0500
In-Reply-To: <20110204153254.5c37c6f2@katamari>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chuck Ebbert <cebbert@redhat.com>
Date: Fri, 4 Feb 2011 15:32:54 -0500

> Analysis is below. (From https://bugzilla.redhat.com/show_bug.cgi?id=674622)
> 
>  BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
>  IP: [<ffffffff81407b16>] tcp_write_xmit+0x694/0x7af

I bet this is some kind of bug in the driver or similar, what device
and also what kind of network config (netfilter, packet scheduler,
interface, routes, etc.) is this?
