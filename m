From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 08:29:14 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0804240828100.2779@woody.linux-foundation.org>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com> <20080424112514.055d8071@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ulrich Drepper <drepper@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47321 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762579AbYDXPaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 11:30:20 -0400
In-Reply-To: <20080424112514.055d8071@the-village.bc.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 24 Apr 2008, Alan Cox wrote:
> 
> Given we will never have 2^32 socket types, and in a sense this is part
> of the type why not just use
> 
> 	socket(PF_INET, SOCK_STREAM|SOCK_CLOEXEC, ...)

Ok, I have to admit that I find this very appealing. It looks much 
cleaner, but perhaps more importantly, it also looks both readable _and_ 
easier to use for the user-space programmer.

		Linus
