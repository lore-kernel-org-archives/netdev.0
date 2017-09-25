From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] r8152:  add Linksys USB3GIGV1 id
Date: Mon, 25 Sep 2017 16:51:14 +0200
Message-ID: <1506351074.7827.13.camel@suse.com>
References: <20170922190604.108155-1-grundler@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-usb <linux-usb@vger.kernel.org>, netdev@vger.kernel.org
To: Grant Grundler <grundler@chromium.org>,
        Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56528 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S936017AbdIYOvV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 25 Sep 2017 10:51:21 -0400
In-Reply-To: <20170922190604.108155-1-grundler@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, den 22.09.2017, 12:06 -0700 schrieb Grant Grundler:
> This Linksys dongle by default comes up in cdc_ether mode.
> This patch allows r8152 to claim the device:
>    Bus 002 Device 002: ID 13b1:0041 Linksys

Hi,

have you tested this in case cdc_ether is for some reason already
loaded? The patch seems to enable r8152 but does not disable
cdc_ether.

	Regards
		Oliver
