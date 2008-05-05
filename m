From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 01/18] flag parameters: helper function
Date: Sun, 4 May 2008 21:45:51 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0805042144320.8307@alien.or.mcafeemobile.com>
References: <200805050342.m453gkY4029814@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	mtk.manpages@gmail.com,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:46965 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118AbYEEEpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 00:45:52 -0400
Received: from alien.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.25 ESMTP Server]
	id <S28A915> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Mon, 5 May 2008 00:45:51 -0400
In-Reply-To: <200805050342.m453gkY4029814@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 4 May 2008, Ulrich Drepper wrote:

> In the following patches we have to map one set of flags to another one
> in numerous locations.  This patch provides a generic implementation for
> this.  It is basically the code Davide Libenzi suggested on 4/27/08.
> 
> I haven't checked whether this functionality can be applied to any existing
> code.
> 
> 
>  include/linux/flagsremap.h |   15 +++++++++++++++
>  lib/Makefile               |    2 +-
>  lib/flagsremap.c           |   17 +++++++++++++++++
>  3 files changed, 33 insertions(+), 1 deletion(-)
> 
> 
> Signed-off-by: Ulrich Drepper <drepper@redhat.com>

I dunno if this deserves separate c/h files. Otherwise ...

Acked-by: Davide Libenzi <davidel@xmailserver.org>



- Davide


