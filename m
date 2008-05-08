From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/18] flag parameters: paccept
Date: Thu, 08 May 2008 15:58:41 -0700 (PDT)
Message-ID: <20080508.155841.88051498.davem@davemloft.net>
References: <200805062118.m46LI7SS004041@devserv.devel.redhat.com>
	<20080508153822.0c4dd6e9.akpm@linux-foundation.org>
	<20080508225043.0A84026FA85@magilla.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, drepper@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davidel@xmailserver.org, mtk.manpages@gmail.com,
	torvalds@linux-foundation.org, oleg@tv-sign.ru
To: roland@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55474
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765761AbYEHW6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 18:58:47 -0400
In-Reply-To: <20080508225043.0A84026FA85@magilla.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland McGrath <roland@redhat.com>
Date: Thu,  8 May 2008 15:50:43 -0700 (PDT)

> It's now spelled:
> 
>        set_restore_sigmask();
> 
> For the other syscalls that depend on this (e.g. sys_ppoll),
> we just put the whole definition in #ifdef HAVE_SET_RESTORE_SIGMASK.
> 
> The few machines that don't have RESTORE_SIGMASK support of some flavor,
> also have not assigned numbers to the syscalls that need it.

I notice that this macro also sets the sigpending bit, although
some paths that end up calling set_restore_sigmask() already
do that.
