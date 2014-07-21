From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH] isdn/capi: avoid index overrun from command_2_index()
Date: Mon, 21 Jul 2014 09:42:32 +0200
Message-ID: <1405928552.6147.143836225.14647899@webmail.messagingengine.com>
References: <20140720134913.13895140074@xenon.ts.pxnet.com>
 <20140720.222545.289290525709647063.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com,
	isdn@linux-pingi.de, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:47991 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752685AbaGUHmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 03:42:33 -0400
In-Reply-To: <20140720.222545.289290525709647063.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 21, 2014, at 07:25, David Miller wrote:
> Command value validation should occur at the callers, signalling
> errors if invalid values are seen, and command_2_index() should
> BUG_ON() such invalid values.

Ok, that's a bigger operation then. I don't have time for that right
now. Any takers?

-- 
Tilman Schmidt
tilman@imap.cc
