From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: prevent the driver from transmitting
 packets with carrier off
Date: Fri, 24 Mar 2017 12:31:35 -0700 (PDT)
Message-ID: <20170324.123135.1629675630856286721.davem@davemloft.net>
References: <1394712342-15778-259-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43418 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967155AbdCXTbg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 15:31:36 -0400
In-Reply-To: <1394712342-15778-259-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 23 Mar 2017 19:14:19 +0800

> The linking status may be changed when autosuspend. And, after
> autoresume, the driver may try to transmit packets when the device
> is carrier off, because the interrupt transfer doesn't update the
> linking status, yet. And, if the device is in ALDPS mode, the device
> would stop working.
> 
> The another similar case is
>  1. unplug the cable.
>  2. interrupt transfer queue a work_queue for linking change.
>  3. device enters the ALDPS mode.
>  4. a tx occurs before the work_queue is called.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied.
