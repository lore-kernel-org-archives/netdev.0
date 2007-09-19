From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.23-rc6 Resending] NETWORKING : Edge Triggered
 EPOLLOUT events get missed for TCP sockets
Date: Wed, 19 Sep 2007 16:10:37 -0700 (PDT)
Message-ID: <20070919.161037.68156707.davem@davemloft.net>
References: <20070919.154402.34760338.davem@davemloft.net>
	<640879.56443.qm@web53701.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davidel@xmailserver.org
To: tomer_iisc@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52542
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751377AbXISXKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 19:10:37 -0400
In-Reply-To: <640879.56443.qm@web53701.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nagendra Tomar <tomer_iisc@yahoo.com>
Date: Wed, 19 Sep 2007 15:55:58 -0700 (PDT)

>      I agree that setting SOCK_NOSPACE would have been a more elegant
> fix. Infact I thought a lot about that before deciding on this fix.

I guess this means you also noticed that you are removing
the one and only test of this bit too?

You can't remove this, it's critical for performance.
