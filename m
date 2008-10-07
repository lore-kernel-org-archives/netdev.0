From: David Miller <davem@davemloft.net>
Subject: Re: Final Bluetooth driver fixes for 2.6.27-rc8
Date: Tue, 07 Oct 2008 15:33:17 -0700 (PDT)
Message-ID: <20081007.153317.147767959.davem@davemloft.net>
References: <1223290955.11272.154.camel@violet.holtmann.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53081
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756484AbYJGWdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 18:33:41 -0400
In-Reply-To: <1223290955.11272.154.camel@violet.holtmann.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Mon, 06 Oct 2008 13:02:35 +0200

> the btusb and bpa10x drivers have double frees due to a thinking mistake
> with the URB_FREE_BUFFER flag. Rafael confirmed that this fixes his last
> hibernation issue. I think that was the last regression that we had for
> this driver. All full suspend/resume and auto-suspend/remote-wakeup
> patches are queued for 2.6.28 now. I am happy that we finally fixed the
> real cause and not worked around it with adding suspend and resume
> callbacks. We did that for the old hci_usb driver and it was a bad idea.
> 
> During the last two weeks also new Bluetooth 2.1 dongles appeared on the
> market and finally I tested all three of them. All of them need a quirk
> entry to make them work. They are all based on the same chip, but they
> are using different vendor and product ids.

Pulled, thanks a lot Marcel.
