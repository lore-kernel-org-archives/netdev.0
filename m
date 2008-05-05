From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/18] flag parameters: paccept
Date: Mon, 05 May 2008 01:13:47 -0700 (PDT)
Message-ID: <20080505.011347.114192937.davem@davemloft.net>
References: <200805050342.m453gkBt029820@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: drepper@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58068
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757676AbYEEINr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 04:13:47 -0400
In-Reply-To: <200805050342.m453gkBt029820@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Drepper <drepper@redhat.com>
Date: Sun, 4 May 2008 23:42:46 -0400

> This patch is by far the most complex in the series.  It adds a new syscall
> paccept.  This syscall differs from accept in that it adds (at the userlevel)
> two additional parameters:
> 
> - a signal mask
> - a flags value
> 
> The flags parameter can be used to set flag like SOCK_CLOEXEC.  This is
> imlpemented here as well.  Some people argued that this is a property
> which should be inherited from the file desriptor for the server but
> this is against POSIX.  Additionally, we really want the signal mask
> parameter as well (similar to pselect, ppoll, etc).  So an interface
> change in inevitable.
> 
> The flag value is the same as for socket and socketpair.  I think
> diverging here will only create confusion.  Similar to the filesystem
> interfaces where the use of the O_* constants differs, it is acceptable
> here.
> 
> The signal mask is handled as for pselect etc.  The mask is temporarily
> installed for the thread and removed before the call returns.  I modeled
> the code after pselect.  If there is a problem it's likely also in
> pselect.
 ...
> Signed-off-by: Ulrich Drepper <drepper@redhat.com>

Acked-by: David S. Miller <davem@davemloft.net>
