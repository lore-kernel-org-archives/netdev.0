From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: appletalk oops.
Date: Fri, 1 Apr 2011 16:26:22 +0200
Message-ID: <201104011626.22656.arnd@arndb.de>
References: <20110331200525.GA17516@redhat.com> <20110331.185823.232755679.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:53515 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757019Ab1DAO00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 10:26:26 -0400
In-Reply-To: <20110331.185823.232755679.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 01 April 2011, David Miller wrote:
> appletalk: Fix OOPS in atalk_release().
> 
> Commit 60d9f461a20ba59219fdcdc30cbf8e3a4ad3f625 ("appletalk: remove
> the BKL") added a dereference of "sk" before checking for NULL in
> atalk_release().
> 
> Guard the code block completely, rather than partially, with the
> NULL check.
> 
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Oops indeed.

The best excuse I have is that nobody who has access to a real
appletalk network stepped up to test it when I submitted the patches
and that I first suggested deleting the protocol instead because
I had no idea if my patch made any sense.

Acked-by: Arnd Bergmann <arnd@arndb.de>
