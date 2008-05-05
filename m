From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/18] flag parameters: socket and socketpair
Date: Mon, 05 May 2008 01:11:14 -0700 (PDT)
Message-ID: <20080505.011114.218022391.davem@davemloft.net>
References: <200805050342.m453gktl029817@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: drepper@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50623
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753298AbYEEILO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 04:11:14 -0400
In-Reply-To: <200805050342.m453gktl029817@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Drepper <drepper@redhat.com>
Date: Sun, 4 May 2008 23:42:46 -0400

> This patch adds support for flag values which are ORed to the type passwd
> to socket and socketpair.  The additional code is minimal.  Beside
> decoding the flags with the library function introduced in a prior patch
> all that has to be done is to pass the new value around.
> 
> The internal functions sock_alloc_fd and sock_map_fd get a new parameters
> and all callers are changed.
...
> Signed-off-by: Ulrich Drepper <drepper@redhat.com>

Acked-by: David S. Miller <davem@davemloft.net>
