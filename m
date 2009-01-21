From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6 multicast routing
Date: Wed, 21 Jan 2009 10:04:31 +0900 (JST)
Message-ID: <20090121.100431.126366547.yoshfuji@linux-ipv6.org>
References: <20090120200248.GA13928@boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fred.l.templin@boeing.com,
	yoshfuji@linux-ipv6.org
To: thomas.goff@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:38546 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755716AbZAUBcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 20:32:39 -0500
In-Reply-To: <20090120200248.GA13928@boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20090120200248.GA13928@boeing.com> (at Tue, 20 Jan 2009 12:02:48 -0800), Tom Goff <thomas.goff@boeing.com> says:

> This patch addresses the IPv6 multicast routing issues described
> below.  It was tested with XORP 1.4/1.5 as the IPv6 PIM-SM routing
> daemon against FreeBSD peers.
:
>   - Enable/disable IPv6 multicast forwarding on the corresponding
>     interface when a routing daemon adds/removes a multicast virtual
>     interface.

Thank you for tha patch!

However, I believe configuring forwarding is user's responsibility
and I'm not in favor of managing mc_forwarding automatically.

If we go your way, we need to make the proc interface read-only, but
you know, they will become non-"conf" interface. :-(
And, well, we will introduce another possible overflow/underflow here...

Another thought was to allow non-VIF routing settings (or manual settings).

So, I decided to drop that bits.


Other fixes seem okay.

--yoshfuji
