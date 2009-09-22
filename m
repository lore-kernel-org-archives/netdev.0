From: David Miller <davem@davemloft.net>
Subject: Re: Resend: [PATCH] TCP Early Retransmit: reduce required dupacks
 for triggering fast retrans
Date: Tue, 22 Sep 2009 13:40:21 -0700 (PDT)
Message-ID: <20090922.134021.82409230.davem@davemloft.net>
References: <fab65f44d75b.4ab891f2@rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christian.Samsel@rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40273
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752520AbZIVUkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 16:40:02 -0400
In-Reply-To: <fab65f44d75b.4ab891f2@rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Samsel <Christian.Samsel@rwth-aachen.de>
Date: Tue, 22 Sep 2009 08:59:30 +0000 (GMT)

> This patch implements draft-ietf-tcpm-early-rexmt. The early retransmit 
> mechanism allows the transport to reduce the number of duplicate
> acknowledgments required to trigger a fast retransmission in case we
> don't expect enough dupacks, (e.g. because there are not enough
> packets inflight and nothing to send). This allows the transport to use
> fast retransmit to recover packet losses that would otherwise require
> a lengthy retransmission timeout.
> 
> See: http://tools.ietf.org/html/draft-ietf-tcpm-early-rexmt-01
> 
> Signed-off-by: Christian Samsel <christian.samsel@rwth-aachen.de>

What changed from the previous version?

Nothing?

If you're resending just to get our attention, please don't do that.

It only creates confusion and makes it take longer for your patch to
get reviewed and applied.
