From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/18] flag parameters: NONBLOCK in socket and
 socketpair
Date: Mon, 05 May 2008 01:16:12 -0700 (PDT)
Message-ID: <20080505.011612.192490132.davem@davemloft.net>
References: <200805050342.m453gkn4029850@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: drepper@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58075
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755002AbYEEIQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 04:16:12 -0400
In-Reply-To: <200805050342.m453gkn4029850@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Drepper <drepper@redhat.com>
Date: Sun, 4 May 2008 23:42:46 -0400

> This patch introduces support for the SOCK_NONBLOCK flag in socket,
> socketpair, and  paccept.  To do this the internal function sock_attach_fd
> gets an additional parameter which it uses to set the appropriate flag for
> the file descriptor.
> 
> Given that in modern, scalable programs almost all socket connections are
> non-blocking and the minimal additional cost for the new functionality
> I see no reason not to add this code.
 ...
> Signed-off-by: Ulrich Drepper <drepper@redhat.com>

Acked-by: David S. Miller <davem@davemloft.net>
