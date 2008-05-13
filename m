From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 18/18] flag parameters: check magic constants
Date: Mon, 12 May 2008 22:19:17 -0700
Message-ID: <20080512221917.07cf7b06.akpm@linux-foundation.org>
References: <200805062118.m46LI74j004096@devserv.devel.redhat.com>
	<20080512201341.9ead6a9a.akpm@linux-foundation.org>
	<482910FA.1080703@redhat.com>
	<20080512.210225.167924945.davem@davemloft.net>
	<20080512220416.ef9a9645.akpm@linux-foundation.org>
	<482922E2.3040902@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41176 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755445AbYEMFUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 01:20:07 -0400
In-Reply-To: <482922E2.3040902@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 May 2008 22:10:58 -0700 Ulrich Drepper <drepper@redhat.com> wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Andrew Morton wrote:
> > m68k too..
> 
> I cannot build it here but looking at the headers:
> 
> - - include/asm-m68k/fcntl.h does not define O_NONBLOCK; and therefore
> 
> - - the definition from include/asm-generic/fcntl.h is used which is 04000
> 
> 
> Is there any magic I miss?
> 

Different bug, I think.

net/socket.c: In function 'sys_paccept':
net/socket.c:1543: error: implicit declaration of function 'set_restore_sigmask'

