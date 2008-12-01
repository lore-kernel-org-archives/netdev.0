From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [patch for 2.6.28? 1/1] bluetooth: Dell Wireless 365 requires
 reset quirk
Date: Mon, 01 Dec 2008 23:03:50 +0100
Message-ID: <1228169030.31158.154.camel@violet.holtmann.net>
References: <200812012201.mB1M155p001654@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, mario_limonciello@dell.com,
	hidave.darkstar@gmail.com, stable@kernel.org,
	tim.gardner@canonical.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:60497 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbYLAWEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 17:04:00 -0500
In-Reply-To: <200812012201.mB1M155p001654@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

> This patch causes the BT365 to be reset when the driver is loaded. 
> Without it, the machine is unable to connect to other devices or to scan
> for devices.
> 
> Signed-off-by: Mario Limonciello <mario_limonciello@dell.com>
> Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
> Cc: Marcel Holtmann <marcel@holtmann.org>
> Cc: Dave Young <hidave.darkstar@gmail.com>
> Cc: <stable@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

NAK. I fixed this differently by making the reset quirk default.

Regards

Marcel


