From: David Miller <davem@davemloft.net>
Subject: Re: Connection reset by peer - need a patch
Date: Fri, 27 Feb 2009 07:28:08 -0800 (PST)
Message-ID: <20090227.072808.98120102.davem@davemloft.net>
References: <20090227150755.GE2796@venus.synerway.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pgs@synerway.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54914
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754766AbZB0P22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 10:28:28 -0500
In-Reply-To: <20090227150755.GE2796@venus.synerway.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pascal GREGIS <pgs@synerway.com>
Date: Fri, 27 Feb 2009 16:07:55 +0100

> Right, but the problem is that I use a kernel 2.6.21.1 and cannot
> upgrade my whole kernel easily.  And in the kernel 2.6.21.1, network
> namespaces don't seem to exist, so I cannot apply this simple patch.

You're chasing a different bug then, the bug was introduced
by a network namespace patch so 2.6.21 can't possibly have
that bug.
