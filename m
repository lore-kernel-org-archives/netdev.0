From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/3] s390: af_iucv: add lock when updating accept_q
Date: Sat, 14 Jul 2007 19:05:25 -0700 (PDT)
Message-ID: <20070714.190525.102575313.davem@davemloft.net>
References: <20070713085053.530802000@linux.vnet.ibm.com>
	<20070713085246.022609000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	fpavlic@de.ibm.com
To: braunu@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52251
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932640AbXGOCFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 22:05:23 -0400
In-Reply-To: <20070713085246.022609000@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>
Date: Fri, 13 Jul 2007 10:50:56 +0200

> From: Ursula Braun <braunu@de.ibm.com>
> 
> The accept_queue of an af_iucv socket will be corrupted, if
> adding and deleting of entries in this queue occurs at the
> same time (connect request from one client, while accept call
> is processed for another client).
> Solution: add locking when updating accept_q
> 
> Signed-off-by: Ursula Braun <braunu@de.ibm.com>
> Acked-by: Frank Pavlic <fpavlic@de.ibm.com>

Also applied, thanks.

In the future please us consistent formatting of your
changelog header lines.  I have to edit them by hand
and I'd like to stop having to do that.

Use something like:

[AF_IUCV]: Blah blah blah.

Thanks :)

