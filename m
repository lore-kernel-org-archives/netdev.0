From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.23-rc6 Resending] NETWORKING : Edge Triggered
 EPOLLOUT events get missed for TCP sockets
Date: Wed, 19 Sep 2007 15:44:02 -0700 (PDT)
Message-ID: <20070919.154402.34760338.davem@davemloft.net>
References: <130356.85796.qm@web53703.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davidel@xmailserver.org
To: tomer_iisc@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39786
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755236AbXISWoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 18:44:05 -0400
In-Reply-To: <130356.85796.qm@web53703.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nagendra Tomar <tomer_iisc@yahoo.com>
Date: Wed, 19 Sep 2007 15:37:09 -0700 (PDT)

> With the SOCK_NOSPACE check in tcp_check_space(), this epoll_wait call will 
> not return, even when the incoming acks free the buffers.
>         Note that this patch assumes that the SOCK_NOSPACE check in
> tcp_check_space is a trivial optimization which can be safely removed.

I already replied to your patch posting explaining that whatever is
not setting SOCK_NOSPACE should be fixed instead.

Please address that, thanks.
