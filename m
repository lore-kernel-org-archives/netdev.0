From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 0/8] CAIF: Bugfixes and updates
Date: Thu, 20 May 2010 15:27:43 -0700 (PDT)
Message-ID: <20100520.152743.46361658.davem@davemloft.net>
References: <1274341448-14924-1-git-send-email-sjur.brandeland@stericsson.com>
	<20100520.005658.11949785.davem@davemloft.net>
	<AANLkTilvQ8W5X-qvt6GvEj-1ZmmfwZJz079Rdi8K6Tll@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sjur.brandeland@stericsson.com, netdev@vger.kernel.org,
	marcel@holtmann.org, daniel.martensson@stericsson.com,
	linus.walleji@stericsson.com
To: sjurbren@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54620
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755024Ab0ETW1e convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 May 2010 18:27:34 -0400
In-Reply-To: <AANLkTilvQ8W5X-qvt6GvEj-1ZmmfwZJz079Rdi8K6Tll@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjurbren@gmail.com>
Date: Thu, 20 May 2010 23:08:27 +0200

> Currently in caif_socket.c caif_seqpkt_recvmsg returns -EMSGSIZE if
> skb don't fit in user buffer.
> Would you consider my patch where I fix MSG_TRUNC to work properly a =
bugfix?

You're really pushing it, but fine...

This is the part I hate most about the merge window, people just
want to slip in as much as they possibly can and justify it by
any means necessary to suit their own personal needs instead of
being amicable and abiding by the merge window rules which is
for the good of everyone.

