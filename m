From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [RFC, PATCH]: Pass link level header from/to PPP interface
Date: 14 Feb 2008 20:02:47 +0100
Message-ID: <ygfzlu3744o.fsf@janus.isnogud.escape.de>
References: <ygfprv55egs.fsf@janus.isnogud.escape.de>
	<20080212.220603.111665989.davem@davemloft.net>
	<ygflk5opzhb.fsf@janus.isnogud.escape.de>
	<20080213.145355.57741113.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:52207 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758692AbYBNTFI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2008 14:05:08 -0500
In-Reply-To: <20080213.145355.57741113.davem@davemloft.net>; from David Miller on Wed, 13 Feb 2008 14:53:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> Can tcpdump and libpcap already handle PPP properly?

Yes, with the (admittedly non-serious) limitation, that both, tcpdump
and tcpdump -e don't show the PPP header.  I don't remember how
tcpdump behaved on BSD in this respect (so many years ago), but I
think libpcap will use the DLT_PPP link type on BSD, which has the PPP
header.

urs
