From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH] ieee802154: fix error handling in ieee802154fake_probe()
Date: Sat, 15 Nov 2014 08:16:06 +0100
Message-ID: <20141115071603.GA3481@omega>
References: <1416006719-3450-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S . Miller" <davem@davemloft.net>,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:35647 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbaKOHQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2014 02:16:14 -0500
Content-Disposition: inline
In-Reply-To: <1416006719-3450-1-git-send-email-khoroshilov@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, Nov 15, 2014 at 02:11:59AM +0300, Alexey Khoroshilov wrote:
> In case of any failure ieee802154fake_probe() just calls unregister_netdev().
> But it does not look safe to unregister netdevice before it was registered.
> 
> The patch implements straightforward resource deallocation in case of
> failure in ieee802154fake_probe().
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 

Thanks for the patch! But I already delete the whole fakehard driver.
The patch to remove this driver is already in net-next.

There was too many issues with the fake hardMAC drivers and we don't
really supported a "real" hardMAC transceiver. For my rework to grab the
good things from wireless implementation and put 802.15.4 functionality
on it I simple delete the whole driver and _maybe_ add a new one with
the new introduced interfaces for possible hardMAC functionality.

This patch could go into bluetooth(net)/stable but I don't think that
there are many users for this driver.

- Alex
