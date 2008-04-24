From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 09:00:08 -0700 (PDT)
Message-ID: <20080424.090008.232544945.davem@davemloft.net>
References: <20080424160352.30f2dd5b@the-village.bc.nu>
	<20080424154441.GG2255@devserv.devel.redhat.com>
	<20080424162444.1c5b9ba2@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub@redhat.com, drepper@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55879
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751623AbYDXQAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 12:00:08 -0400
In-Reply-To: <20080424162444.1c5b9ba2@the-village.bc.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Thu, 24 Apr 2008 16:24:44 +0100

> BTW in 4.4BSD and derivatives if I remember rightly F_CLOEXEC *is*
> inherited across accept() so I doubt any user space software will be too
> upset by such a shift.

It actually doesn't.

Just like in Linux, no file descriptor flags are inherited.
