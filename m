From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] tg3: Add external loopback support to
 selftest
Date: Sat, 20 Aug 2011 10:38:00 -0700 (PDT)
Message-ID: <20110820.103800.1829588763643418877.davem@davemloft.net>
References: <1313798304-26171-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40427 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382Ab1HTRiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2011 13:38:02 -0400
In-Reply-To: <1313798304-26171-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 19 Aug 2011 16:58:18 -0700

> This patchset adds external loopback support to the driver's selftest code.

Even the very first patch doesn't apply, the tg3_test_loopback() function
lacks any of that "cpmuctrl" code that is being removed.

Now it does exist in the plain "net" tree, but if your patches have
such a dependency upon me pulling those changes into net-next FIRST,
how in the world do you expect me to know it unless you tell me?
