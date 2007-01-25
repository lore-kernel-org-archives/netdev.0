From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix sorting of SACK blocks
Date: Thu, 25 Jan 2007 13:34:25 -0800 (PST)
Message-ID: <20070125.133425.123974028.davem@davemloft.net>
References: <20070125182903.GA22455@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@osdl.org
To: baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56101
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030584AbXAYVe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 16:34:26 -0500
In-Reply-To: <20070125182903.GA22455@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baruch Even <baruch@ev-en.org>
Date: Thu, 25 Jan 2007 20:29:03 +0200

> The sorting of SACK blocks actually munges them rather than sort, causing the
> TCP stack to ignore some SACK information and breaking the assumption of
> ordered SACK blocks after sorting.
> 
> The sort takes the data from a second buffer which isn't moved causing
> subsequent data moves to occur from the wrong location. The fix is to
> use a temporary buffer as a normal sort does.
> 
> Signed-Off-By: Baruch Even <baruch@ev-en.org>

Thanks for finding this bug Baruch.

It probably explains some weird TCP traces I've seen over
the years :-)

I'll review this and apply it later today, thanks again.
