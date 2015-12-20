From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH bluetooth-next] 6lowpan: fix debugfs interface entry name
Date: Sun, 20 Dec 2015 08:22:04 +0100
Message-ID: <60F184F1-1E10-4D0E-92F8-C778E6FF8386@holtmann.org>
References: <1450178735-1572-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wpan@vger.kernel.org,
	BlueZ development <linux-bluetooth@vger.kernel.org>,
	netdev@vger.kernel.org, kernel@pengutronix.de,
	lukasz.duda@nordicsemi.no
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [82.165.8.211] ([82.165.8.211]:51609 "EHLO mail.holtmann.org"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751402AbbLTHWI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Dec 2015 02:22:08 -0500
In-Reply-To: <1450178735-1572-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alex,

> This patches moves the debugfs interface related register after
> netdevice register. The function lowpan_dev_debugfs_init will use
> "dev->name" which can be before register_netdevice a format string.
> The function register_netdevice will evaluate the format string if
> necessary and replace "dev->name" to the real interface name.
> 
> Reported-by: Lukasz Duda <lukasz.duda@nordicsemi.no>
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> ---
> net/6lowpan/core.c | 6 +++---
> 1 file changed, 3 insertions(+), 3 deletions(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
