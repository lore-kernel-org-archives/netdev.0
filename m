From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Consolidate udp hash calculations
Date: Mon, 07 May 2007 00:04:47 -0700 (PDT)
Message-ID: <20070507.000447.71091688.davem@davemloft.net>
References: <463B4878.4060902@sw.ru>
	<20070504.123909.88476080.davem@davemloft.net>
	<463ED023.4060109@sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57711
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754076AbXEGHEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2007 03:04:45 -0400
In-Reply-To: <463ED023.4060109@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelianov <xemul@sw.ru>
Date: Mon, 07 May 2007 11:07:15 +0400

> David Miller wrote:
> > I can only assume you wish to do something with the UDP hash table
> > sizes, and therefore only want to have a need to touch one function.
> 
> You are right, I have told that this must help network namespaces,
> by making the hash differ depending on the namespace passed.

Then make your code rearrangements as part of your namespace
patches so we can see what the consolidation is even for.
