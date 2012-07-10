From: David Miller <davem@davemloft.net>
Subject: Re: [net-next patch v2] bnx2x: Add run-time CNIC support
Date: Tue, 10 Jul 2012 05:21:49 -0700 (PDT)
Message-ID: <20120710.052149.792836375666491854.davem@davemloft.net>
References: <1341828055-4467-1-git-send-email-meravs@broadcom.com>
	<20120709.141010.996787793429264956.davem@davemloft.net>
	<1341922620.27284.16.camel@lb-tlvb-meravs.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, dmitry@broadcom.com
To: meravs@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37163 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752822Ab2GJMVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 08:21:52 -0400
In-Reply-To: <1341922620.27284.16.camel@lb-tlvb-meravs.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Merav Sicron" <meravs@broadcom.com>
Date: Tue, 10 Jul 2012 15:17:00 +0300

> There are still two advantages in disabling CNIC in bnx2x: Saving
> resources (MSI-X vector and memory) as well as reducing some latency.

But, nobody does this.  No end user can do this easily, this
is therefore of zero value to him.

> While it is true that distributions enable the CNIC Kconfig option, some
> users that care about resources and latency compile a kernel without it.

This, therefore, results in a terrible user experience.

> Can you please re-consider this patch?

Absolutely not.

Make it really dynamic, and properly configurable at run time, so
people don't have to go through hoops to get the "advantages" you
speak so highly of.
