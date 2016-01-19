From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/1] af_iucv: Validate socket address length in
 iucv_sock_bind()
Date: Tue, 19 Jan 2016 14:23:57 -0500 (EST)
Message-ID: <20160119.142357.829571599757607853.davem@davemloft.net>
References: <1453196493-57590-1-git-send-email-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschwid2@linux.vnet.ibm.com, heicars2@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ubraunu@linux.vnet.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932702AbcASTYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 14:24:01 -0500
In-Reply-To: <1453196493-57590-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Tue, 19 Jan 2016 10:41:32 +0100

> this patch fixes a problem reported by Dmitry Vyukov in december. It is built
> and intended for the next-tree.

A bug fix is not appropriate for the next tree.

All bug fixes should target 'net'.  You even contacted me privately
asking me to queue this up for -stable.  Submitting something for
net-next and wanting a -stable backport is doubly inappropriate.

Things don't go to -stable unless it's in Linus's tree.  'net' is
for bug fixes, 'net-next' (closed right now) is for new features,
cleanups, and fixes to code only present in 'net-next'.

Anyways I applied this to 'net' and queued it up for -stable.
