From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: patch "appletalk: move to staging" added to staging tree
Date: Mon, 31 Jan 2011 22:55:39 +0100
Message-ID: <201101312255.39981.arnd@arndb.de>
References: <12965099622238@site>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:56575 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754104Ab1AaVzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 16:55:53 -0500
In-Reply-To: <12965099622238@site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 31 January 2011, gregkh@suse.de wrote:
> 
> This is a note to let you know that I've just added the patch titled
> 
>     appletalk: move to staging
> 
> to my staging git tree which can be found at
>     git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-2.6.git
> in the staging-next branch.

Actually, David Miller objected to this patch for good reasons, please
revert it. One of the other patches removes the BKL in appletalk, so
we should find a way to keep it.

	Arnd
