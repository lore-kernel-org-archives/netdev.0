From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] [IrDA] af_irda: Silence kernel message in
 irda_recvmsg_stream
Date: Fri, 20 Apr 2007 22:09:00 -0700 (PDT)
Message-ID: <20070420.220900.45154094.davem@davemloft.net>
References: <20070418213202.214829666@sortiz.org>
	<20070418214750.515230054@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	olaf.kirch@oracle.com
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55779
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754465AbXDUFI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2007 01:08:57 -0400
In-Reply-To: <20070418214750.515230054@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: samuel@sortiz.org
Date: Thu, 19 Apr 2007 00:32:04 +0300

> From: Olaf Kirch <olaf.kirch@oracle.com>
> 
> This patch silences an IRDA_ASSERT in irda_recvmsg_stream, as described in
> http://bugzilla.kernel.org/show_bug.cgi?id=7512 irda_disconnect_indication
> would set sk->sk_err to ECONNRESET, and a subsequent call to recvmsg
> would print an irritating kernel message and return -1.
> 
> When a connected socket is closed by the peer, recvmsg should return 0
> rather than an error. This patch fixes this.
> 
> Signed-off-by: Olaf Kirch <olaf.kirch@oracle.com>
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

There were some conflicts in this one wrt. the sock_orphan()
bug fix we put into mainline recently, but I did my best
to resolve it when I applied this to net-2.6.22

You can have a look and verify things when I put up my net-2.6.2
tree later this evening.

Thanks.
