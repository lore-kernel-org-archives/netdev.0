From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] (Revised) USB VID/PID clash between pegasus and
	hci_usb drivers
Date: Fri, 04 Jan 2008 13:45:06 +0100
Message-ID: <1199450706.26099.60.camel@aeonflux>
References: <130968.6446.qm@web52904.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greg@kroah.com
To: Chris Rankin <rankincj@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:48586 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605AbYADMpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 07:45:46 -0500
In-Reply-To: <130968.6446.qm@web52904.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chris,

> I have surprisingly managed to track down the USB device descriptor for the wired Belkin network
> adapter, and it looks as if the device class is actually 0x00 instead of 0xFF. I originally used
> 0xFF because that is what my 3com device used (for some reason) and so I was hoping that Belkin
> would also use 0xFF for the same reason.

can you please follow Documentation/SubmittingPatches. The commit
message should explain why this is needed and why this change is the
best choice.

The patch itself is Acked-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel


