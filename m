From: Roland McGrath <roland@redhat.com>
Subject: Re: [PATCH 02/18] flag parameters: paccept
Date: Thu,  8 May 2008 15:50:43 -0700 (PDT)
Message-ID: <20080508225043.0A84026FA85@magilla.localdomain>
References: <200805062118.m46LI7SS004041@devserv.devel.redhat.com>
	<20080508153822.0c4dd6e9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ulrich Drepper <drepper@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org,
	Oleg Nesterov <oleg@tv-sign.ru>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55950 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762266AbYEHWuu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 18:50:50 -0400
In-Reply-To: Andrew Morton's message of  Thursday, 8 May 2008 15:38:22 -0700 <20080508153822.0c4dd6e9.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Some architectures (including x86) do not implement TIF_RESTORE_SIGMASK.

It's now spelled:

       set_restore_sigmask();

For the other syscalls that depend on this (e.g. sys_ppoll),
we just put the whole definition in #ifdef HAVE_SET_RESTORE_SIGMASK.

The few machines that don't have RESTORE_SIGMASK support of some flavor,
also have not assigned numbers to the syscalls that need it.


Thanks,
Roland
