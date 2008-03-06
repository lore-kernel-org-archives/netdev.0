From: David Miller <davem@davemloft.net>
Subject: udplite split-out
Date: Thu, 06 Mar 2008 15:12:26 -0800 (PST)
Message-ID: <20080306.151226.233101786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32942
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755983AbYCFXM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 18:12:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I think I'm going to revert this.

Firstly, as far as I can tell this specific change was not discussed
at all on netdev, it was just included inside of the ipv6 pull
request.  This is always wrong.

Secondly, udplite is of such small cost, and it is a core protocol
just like TCP and normal UDP are.

We spent enormous amounts of effort to make udplite share as much
code with core UDP as possible.  All of that work is less
valuable if we're just going to slap a config option on udplite
support.

It is also causing build failures, as reported on linux-next, showing
that the changeset was not tested very well.  In fact, this is the
second build failure resulting from the udplite change.

Therefore I am reverting it, sorry.
