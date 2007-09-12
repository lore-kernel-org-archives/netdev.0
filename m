From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Clean up owner field in sock_lock_t
Date: Wed, 12 Sep 2007 01:45:46 -0700 (PDT)
Message-ID: <20070912.014546.78722298.davem@davemloft.net>
References: <11895336933187-git-send-email-jheffner@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:54502
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756620AbXILIp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 04:45:56 -0400
In-Reply-To: <11895336933187-git-send-email-jheffner@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Tue, 11 Sep 2007 14:01:31 -0400

> I don't know why the owner field is a (struct sock_iocb *).  I'm assuming
> it's historical.  Can someone check this out?  Did I miss some alternate
> usage?

AIO used it somehow in net/socket.c and I believe there was some
intention to access this sock_iocb deeper in the call chain.

None of that materialized of course :)

> These patches are against net-2.6.24.

Thanks a lot, I'll add these patches.
