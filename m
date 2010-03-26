From: David Miller <davem@davemloft.net>
Subject: Re: UDP path MTU discovery
Date: Thu, 25 Mar 2010 20:26:36 -0700 (PDT)
Message-ID: <20100325.202636.149498207.davem@davemloft.net>
References: <1269561751.2891.8.camel@ilion>
	<4BAC0577.7070803@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gdt@gdt.id.au, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45291
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753870Ab0CZD0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 23:26:13 -0400
In-Reply-To: <4BAC0577.7070803@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Thu, 25 Mar 2010 17:53:11 -0700

> So, presuming it is indeed a bug what form might a fix take? Are you
> suggesting there should be a way for an application to say "Please let
> me see/know about the ICMP messages?"  Is that option available on
> other platforms as a platform-specific extension?

We already provide this information.

The socket ends up with EMSGSIZE in it's error queue, so the next time
the application does I/O it sees that error immediately from the
read/write call and thus knows that path MTU arrived.
