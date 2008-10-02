From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Two more Bluetooth btusb fixes for 2.6.27-rc8
Date: Thu, 02 Oct 2008 15:41:49 +0200
Message-ID: <1222954909.11272.24.camel@violet.holtmann.net>
References: <1222812817.1825.75.camel@violet.holtmann.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:41597 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913AbYJBNlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 09:41:47 -0400
In-Reply-To: <1222812817.1825.75.camel@violet.holtmann.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> the btusb and bpa10x drivers have double frees due to a thinking mistake
> with the URB_FREE_BUFFER flag. Rafael confirmed that this fixes his last
> hibernation issue. I think that was the last regression that we had for
> this driver. All full suspend/resume and auto-suspend/remote-wakeup
> patches are queued for 2.6.28 now. I am happy that we finally fixed the
> real cause and not worked around it with adding suspend and resume
> callbacks. We did that for the old hci_usb driver and it was a bad idea.
> 
> I also added a second patch for two new Bluetooth 2.1 devices that came
> to market recently that need a quirk to make them work. Both are based
> on the same chip, but use different vendor ids. I tested the Targus one
> personally.

did you see this one? Any objections for pulling it? The Nokia guys just
told me they got another device that needs the HCI_Reset quirk. If you
haven't pulled this yet, I like to push that one on top of these
patches.

Regards

Marcel


