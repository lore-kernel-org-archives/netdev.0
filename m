From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH] net: usb: r8152: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 13 Mar 2017 09:25:36 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB201A2DC71@RTITMBSV06.realtek.com.tw>
References: <1489354918-6650-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Philippe Reynes <tremyfr@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "jarod@redhat.com" <jarod@redhat.com>,
        "mario_limonciello@dell.com" <mario_limonciello@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([211.75.126.72]:40255 "EHLO
        rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752020AbdCMJ0G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 05:26:06 -0400
In-Reply-To: <1489354918-6650-1-git-send-email-tremyfr@gmail.com>
Content-Language: zh-TW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Philippe Reynes [mailto:tremyfr@gmail.com]
> Sent: Monday, March 13, 2017 5:42 AM
> Subject: [PATCH] net: usb: r8152: use new api ethtool_{get|set}_link_ksettings
> 
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
>  drivers/net/usb/r8152.c |   21 ++++++++++++---------
>  1 files changed, 12 insertions(+), 9 deletions(-)

Acked-by: Hayes Wang <hayeswang@realtek.com>
