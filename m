From: David Miller <davem@davemloft.net>
Subject: Re: [patch 07/11] bluetooth: add quirks for a few hci_usb devices
Date: Wed, 30 Jul 2008 17:00:08 -0700 (PDT)
Message-ID: <20080730.170008.147267953.davem@davemloft.net>
References: <200807301937.m6UJbdJk012449@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben.collins@canonical.com,
	Mario_Limonciello@Dell.com, hidave.darkstar@gmail.com,
	marcel@holtmann.org, michael.frey@canonical.com,
	tim.gardner@canonical.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53321
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752296AbYGaAAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 20:00:08 -0400
In-Reply-To: <200807301937.m6UJbdJk012449@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 30 Jul 2008 12:37:39 -0700

> From: Ben Collins <ben.collins@canonical.com>
> 
> Preface: The "Broadcom" device is on unreleased hardware, so I can't
> disclose the actual model.
> 
> When the Dell 370 and 410 BT adapters are put into BT radio mode, they
> need to be prepared like many other Broadcom adapters.
> 
> Also, add quirk Broadcom 2046 devices with HCI_RESET.  Reference for this
> bug: https://launchpad.net/bugs/249448
> 
> Signed-off-by: Michael Frey <michael.frey@canonical.com>
> Signed-off-by: Mario Limonciello <Mario_Limonciello@Dell.com>
> Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
> Signed-off-by: Ben Collins <ben.collins@canonical.com>
> Acked-by: Marcel Holtmann <marcel@holtmann.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

My understanding is that Michael Frey wrote this patch, and Ben
was just submitting it to us from the pile of Ubuntu kernel bits
he has.

So I've applied this, marking Michael as the patch author.

Let me know if I got that wrong and I'll fix it up before
pushing the change out to the net-2.6 tree.

Thanks!
