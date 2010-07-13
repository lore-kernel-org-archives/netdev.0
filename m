From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/12] isdn: autoconvert trivial BKL users to private
 mutex
Date: Mon, 12 Jul 2010 20:35:40 -0700 (PDT)
Message-ID: <20100712.203540.26940801.davem@davemloft.net>
References: <1278883143-29035-1-git-send-email-arnd@arndb.de>
	<1278883143-29035-3-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jkacur@redhat.com,
	fweisbec@gmail.com, isdn@linux-pingi.de, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41483
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752349Ab0GMDfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 23:35:25 -0400
In-Reply-To: <1278883143-29035-3-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Sun, 11 Jul 2010 23:18:53 +0200

> All these files use the big kernel lock in a trivial
> way to serialize their private file operations,
> typically resulting from an earlier semi-automatic
> pushdown from VFS.
> 
> None of these drivers appears to want to lock against
> other code, and they all use the BKL as the top-level
> lock in their file operations, meaning that there
> is no lock-order inversion problem.
> 
> Consequently, we can remove the BKL completely,
> replacing it with a per-file mutex in every case.
> Using a scripted approach means we can avoid
> typos.
...
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
