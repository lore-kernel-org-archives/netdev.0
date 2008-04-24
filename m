From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] socket, socketpair w/flags, accept4
Date: Thu, 24 Apr 2008 21:58:58 +0100
Message-ID: <20080424215858.771f718a@the-village.bc.nu>
References: <200804241820.m3OIKlMK017580@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:47404 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751205AbYDXV2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 17:28:14 -0400
In-Reply-To: <200804241820.m3OIKlMK017580@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The code changes are really minimal.  And don't get too hung up on the
> internal name of the syscall.  I think accept4 is more desriptive than
> paccept since a) suffixes more easily indicate derived functionality
> and b) the 4 actually indicates to the initiated what has changed.

Names can be argued about separately to functionality. Can we also get
the behaviour of flag inheritance and other stuff defined in any future
API spec for this so it is consistent across platforms too - that will
also let the new accept be used in the longer term to make portable code
easier.

Alan
