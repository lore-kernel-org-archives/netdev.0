From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 9174] New: linux-2.6.23-git11 kernel panic
Date: Thu, 18 Oct 2007 05:09:38 -0700 (PDT)
Message-ID: <20071018.050938.75431271.davem@davemloft.net>
References: <20071017130131.365f9fb6.akpm@linux-foundation.org>
	<47172D10.2040309@trash.net>
	<47173C62.5080302@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: plamen.petrov@tk.ru.acad.bg, akpm@linux-foundation.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50784
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762294AbXJRMJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 08:09:25 -0400
In-Reply-To: <47173C62.5080302@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 18 Oct 2007 12:58:42 +0200

> Patrick McHardy wrote:
> > Andrew Morton wrote:
> >> On Wed, 17 Oct 2007 07:36:16 -0700 (PDT)
> >> bugme-daemon@bugzilla.kernel.org wrote:
> >>
> >>> http://bugzilla.kernel.org/show_bug.cgi?id=9174
> >>>
> >>>            Summary: linux-2.6.23-git11 kernel panic
> >  >>
> > 
> >>> EIP is at packet_rcv_0x1a2/0x360
> > 
> > 
> > Please find out on which device the packet socket is opened by
> > looking at /proc/net/packet and comparing the Iface shown there
> > to the ifindexes listed in "ip link list".
> 
> 
> Well, he replied in private mail, the device in question is
> an IPv6-over-IPv4 tunnel, which doesn't have any header_ops,
> so the crash happens in dev_parse_header when dereferencing
> them.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick!
