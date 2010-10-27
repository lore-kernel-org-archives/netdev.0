From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: Remove a dangerous debug print.
Date: Wed, 27 Oct 2010 12:30:43 -0700 (PDT)
Message-ID: <20101027.123043.241428851.davem@davemloft.net>
References: <1288206788-21063-1-git-send-email-nelhage@ksplice.com>
	<20101027.122143.02260950.davem@davemloft.net>
	<20101027192808.GP16803@ksplice.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, eugene@redhat.com
To: nelhage@ksplice.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59207
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753857Ab0J0TaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 15:30:20 -0400
In-Reply-To: <20101027192808.GP16803@ksplice.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nelson Elhage <nelhage@ksplice.com>
Date: Wed, 27 Oct 2010 15:28:08 -0400

> How would you feel about limiting the debug print to at most, say, 512 or 1024
> bytes? Even if it's only accessible to root by default, I don't a userspace
> program should be able to accidentally corrupt the kernel stack by writing too
> many bytes to a file in /proc.

Why not?  He can just as easily "cat whatever >/dev/kmem" or similar?
And I'm sure there are other proc files that can cause similar damage
such as the PCI device control files.
