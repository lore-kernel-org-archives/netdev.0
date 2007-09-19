From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 2.6.23-rc6 Resending] NETWORKING : Edge Triggered EPOLLOUT
 events get missed for TCP sockets
Date: Wed, 19 Sep 2007 16:11:45 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0709191552171.2989@alien.or.mcafeemobile.com>
References: <130356.85796.qm@web53703.mail.re2.yahoo.com>
 <20070919.154402.34760338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: tomer_iisc@yahoo.com, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:42542 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753862AbXISXLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 19:11:48 -0400
Received: from alien.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.25 ESMTP Server]
	id <S24EA62> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Wed, 19 Sep 2007 19:11:46 -0400
In-Reply-To: <20070919.154402.34760338.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Sep 2007, David Miller wrote:

> From: Nagendra Tomar <tomer_iisc@yahoo.com>
> Date: Wed, 19 Sep 2007 15:37:09 -0700 (PDT)
> 
> > With the SOCK_NOSPACE check in tcp_check_space(), this epoll_wait call will 
> > not return, even when the incoming acks free the buffers.
> >         Note that this patch assumes that the SOCK_NOSPACE check in
> > tcp_check_space is a trivial optimization which can be safely removed.
> 
> I already replied to your patch posting explaining that whatever is
> not setting SOCK_NOSPACE should be fixed instead.
> 
> Please address that, thanks.

You're not planning of putting the notion of a SOCK_NOSPACE bit inside a 
completely device-unaware interface like epoll, I hope?



- Davide


