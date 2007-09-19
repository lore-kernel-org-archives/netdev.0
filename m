From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.23-rc6] NETWORKING : Edge Triggered EPOLLOUT events
 get missed for TCP sockets
Date: Wed, 19 Sep 2007 09:02:09 -0700 (PDT)
Message-ID: <20070919.090209.73655853.davem@davemloft.net>
References: <106538.13069.qm@web53707.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tomer_iisc@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59368
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754793AbXISQCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 12:02:25 -0400
In-Reply-To: <106538.13069.qm@web53707.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nagendra Tomar <tomer_iisc@yahoo.com>
Date: Wed, 19 Sep 2007 04:13:24 -0700 (PDT)

> With the SOCK_NOSPACE check in tcp_check_space(), this epoll_wait call will 
> not return, even when the incoming acks free the buffers.
>         Note that this patch assumes that the SOCK_NOSPACE check in
> tcp_check_space is a trivial optimization which can be safely removed.

I think the more correct fix is to fix whoever isn't
setting the SOCK_NOSPACE bit, that check really is
crucial.
