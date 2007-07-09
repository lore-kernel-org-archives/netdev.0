From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] [2.6.22] Fix a potential NULL pointer dereference in
 free_shared_mem() in drivers/net/s2io.c
Date: Sun, 08 Jul 2007 23:25:50 -0400
Message-ID: <4691AABE.5030609@pobox.com>
References: <aaab98560707082024v106a61c1r501ef9817e029410@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Micah Gruber <micah.gruber@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44472 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758555AbXGIDZw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jul 2007 23:25:52 -0400
In-Reply-To: <aaab98560707082024v106a61c1r501ef9817e029410@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Micah Gruber wrote:
> This patch fixes a potential null dereference bug where we dereference 
> nic before a null check. This patch simply moves the dereferencing after 
> the null check.
> 
> Signed-off-by: Micah Gruber < micah.gruber@gmail.com 
> <mailto:micah.gruber@gmail.com>>

any chance you can resend in an email format other than format=flowed?

	Jeff



