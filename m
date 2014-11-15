From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] ieee802154: fix error handling in ieee802154fake_probe()
Date: Sat, 15 Nov 2014 16:58:28 +0900
Message-ID: <B1D43522-B042-4D92-8F8A-D2AD89A3F0F9@holtmann.org>
References: <1416006719-3450-1-git-send-email-khoroshilov@ispras.ru> <20141115071603.GA3481@omega>
Mime-Version: 1.0 (Mac OS X Mail 8.0 \(1990.1\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	linux-wpan@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	ldv-project@linuxtesting.org
To: Alexander Aring <alex.aring@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:52082 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120AbaKOH6g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2014 02:58:36 -0500
In-Reply-To: <20141115071603.GA3481@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alex,

>> In case of any failure ieee802154fake_probe() just calls unregister_netdev().
>> But it does not look safe to unregister netdevice before it was registered.
>> 
>> The patch implements straightforward resource deallocation in case of
>> failure in ieee802154fake_probe().
>> 
>> Found by Linux Driver Verification project (linuxtesting.org).
>> 
> 
> Thanks for the patch! But I already delete the whole fakehard driver.
> The patch to remove this driver is already in net-next.
> 
> There was too many issues with the fake hardMAC drivers and we don't
> really supported a "real" hardMAC transceiver. For my rework to grab the
> good things from wireless implementation and put 802.15.4 functionality
> on it I simple delete the whole driver and _maybe_ add a new one with
> the new introduced interfaces for possible hardMAC functionality.
> 
> This patch could go into bluetooth(net)/stable but I don't think that
> there are many users for this driver.

I am not sure that this is worth it then.

Dave, do you want to just take it via net-stable tree? We currently have no urgent bluetooth-stable tree patches pending.

Regards

Marcel
