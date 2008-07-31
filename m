From: Ben Collins <ben.collins@canonical.com>
Subject: Re: [patch 07/11] bluetooth: add quirks for a few hci_usb devices
Date: Thu, 31 Jul 2008 11:13:41 -0400
Message-ID: <1217517221.29588.100.camel@cunning>
References: <200807301937.m6UJbdJk012449@imap1.linux-foundation.org>
	 <20080730.170008.147267953.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	Mario_Limonciello@Dell.com, hidave.darkstar@gmail.com,
	marcel@holtmann.org, michael.frey@canonical.com,
	tim.gardner@canonical.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adelie.canonical.com ([91.189.90.139]:58956 "EHLO
	adelie.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752320AbYGaPNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 11:13:49 -0400
In-Reply-To: <20080730.170008.147267953.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-07-30 at 17:00 -0700, David Miller wrote:
> From: akpm@linux-foundation.org
> Date: Wed, 30 Jul 2008 12:37:39 -0700
> 
> > From: Ben Collins <ben.collins@canonical.com>
> > 
> > Preface: The "Broadcom" device is on unreleased hardware, so I can't
> > disclose the actual model.
> > 
> > When the Dell 370 and 410 BT adapters are put into BT radio mode, they
> > need to be prepared like many other Broadcom adapters.
> > 
> > Also, add quirk Broadcom 2046 devices with HCI_RESET.  Reference for this
> > bug: https://launchpad.net/bugs/249448
> > 
> > Signed-off-by: Michael Frey <michael.frey@canonical.com>
> > Signed-off-by: Mario Limonciello <Mario_Limonciello@Dell.com>
> > Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
> > Signed-off-by: Ben Collins <ben.collins@canonical.com>
> > Acked-by: Marcel Holtmann <marcel@holtmann.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> My understanding is that Michael Frey wrote this patch, and Ben
> was just submitting it to us from the pile of Ubuntu kernel bits
> he has.
> 
> So I've applied this, marking Michael as the patch author.
> 
> Let me know if I got that wrong and I'll fix it up before
> pushing the change out to the net-2.6 tree.

The patch actually has three authors (one for each device), so I just
collapsed it into one patch. I'm not concerned about my authorship being
shown properly, so leaving it as Michael is fine by me :)

