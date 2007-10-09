From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8][BNX2X] resubmit as attachments: add bnx2x to
 Kconfig and Makefile
Date: Mon, 08 Oct 2007 17:46:03 -0700 (PDT)
Message-ID: <20071008.174603.55855492.davem@davemloft.net>
References: <470A5795.2000809@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, mchan@broadcom.com
To: eliezert@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58182
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751728AbXJIAqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 20:46:04 -0400
In-Reply-To: <470A5795.2000809@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eliezer Tamir" <eliezert@broadcom.com>
Date: Mon, 08 Oct 2007 18:15:17 +0200

> Add bnx2x to Kconfig and Makefile

In a patch submission, the tree should build on every step along the
way in applying your patches, with any given configuration.

Here, the user (or something automated like "make allmodconfig") can
select the new config option, but because the driver source hasn't
been added, the compile will fail.

The idea is that if your patch set really is composed of logically
seperate changes, you submit them one logical compilable piece at a
time, and if the first few patches are ok, they could go right in
whilst we work out issues in later patches.  But that's not how
a new driver is, it is logically one change only.

You go on next to add a foo.c file, and then a foo.h file.
This makes things even more difficult to review.

Really, for a new driver that doesn't make any generic kernel code
changes, just submit the whole thing in one shot.  It's the only
reasonable way.

Thank you.
