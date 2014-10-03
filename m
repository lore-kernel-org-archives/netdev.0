From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] net: spider_net: avoid using signed char for bitops
Date: Fri, 03 Oct 2014 17:15:05 +0200
Message-ID: <9201792.OAu7xPjvdN@wuerfel>
References: <1412348517-20352-1-git-send-email-antoine.tenart@free-electrons.com> <1412348517-20352-4-git-send-email-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	dan.carpenter@oracle.com, kou.ishizaki@toshiba.co.jp,
	jens@de.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:55571 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679AbaJCPPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 11:15:12 -0400
In-Reply-To: <1412348517-20352-4-git-send-email-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 03 October 2014 17:01:56 Antoine Tenart wrote:
> Signedness bugs may occur when using signed char for bitops,
> depending on if the highest bit is ever used.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> 

It's probably worth mentioning here that this cannot happen in this
driver because it's only used in one powerpc-specific chip, and 'char'
is always 'unsigned' on powerpc.

	Arnd
