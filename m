From: Andi Kleen <andi@firstfloor.org>
Subject: Re: follow-up: discrepancy with POSIX
Date: 19 Sep 2007 17:47:50 +0200
Message-ID: <p73sl5aveqh.fsf@bingen.suse.de>
References: <46F13E8B.4050309@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:60595 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755724AbXISPrv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 11:47:51 -0400
In-Reply-To: <46F13E8B.4050309@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ulrich Drepper <drepper@redhat.com> writes:

> 
>    fd = socket(AT_INET6, ...)
> 
>    connect(fd, ...some IPv6 address...)
> 
>    struct sockaddr_in6 sin6 = { .sin6_family = AF_INET6 };
>    connect(fd, &sin6, sizeof (sin6));

The standard way to undo connect is to use AF_UNSPEC. Code to handle
that for dgram sockets is there. It's the same code for v4 and v6.

-Andi

