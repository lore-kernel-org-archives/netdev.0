From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Make skb_seq_read unmap the last fragment
Date: Sat, 23 Jun 2007 23:12:07 -0700 (PDT)
Message-ID: <20070623.231207.44965284.davem@davemloft.net>
References: <200706190956.26252.okir@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: okir@lst.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54107
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753676AbXFXGLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 02:11:49 -0400
In-Reply-To: <200706190956.26252.okir@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olaf Kirch <okir@lst.de>
Date: Tue, 19 Jun 2007 09:56:24 +0200

> From: Olaf Kirch <olaf.kirch@oracle.com>
> 
> Make skb_seq_read unmap the last fragment
> 
> Having walked through the entire skbuff, skb_seq_read would leave the
> last fragment mapped.  As a consequence, the unwary caller would leak
> kmaps, and proceed with preempt_count off by one. The only (kind of
> non-intuitive) workaround is to use skb_seq_read_abort.
> 
> This patch makes sure skb_seq_read always unmaps frag_data after having
> cycled through the skb's paged part.
> 
> Signed-off-by: olaf.kirch@oracle.com

Thanks for finding and fixing this bug.

Patch applied, thanks again Olaf.
