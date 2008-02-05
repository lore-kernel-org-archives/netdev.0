From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/7] bluetooth: hidp_process_hid_control remove
 unnecessary parameter dealing
Date: Tue, 05 Feb 2008 03:07:24 -0800 (PST)
Message-ID: <20080205.030724.134782933.davem@davemloft.net>
References: <200802050747.m157lt6g010446@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, netdev@vger.kernel.org,
	hidave.darkstar@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46088
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756758AbYBELG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 06:06:57 -0500
In-Reply-To: <200802050747.m157lt6g010446@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 04 Feb 2008 23:48:13 -0800

> From: Dave Young <hidave.darkstar@gmail.com>
> 
> According to the bluetooth HID spec v1.0 chapter 7.4.2
> 
> "This code requests a major state change in a BT-HID device.  A HID_CONTROL
> request does not generate a HANDSHAKE response."
> 
> "A HID_CONTROL packet with a parameter of VIRTUAL_CABLE_UNPLUG is the only
> HID_CONTROL packet a device can send to a host.  A host will ignore all other
> packets."
> 
> So in the hidp_precess_hid_control function, we just need to deal with the
> UNLUG packet.
> 
> Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
> Cc: Marcel Holtmann <marcel@holtmann.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
