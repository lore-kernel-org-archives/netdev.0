From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net 2/2] r8152: rx descriptor check
Date: Thu, 17 Nov 2016 03:05:14 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB201050063@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
 <1394712342-15778-228-Taiwan-albertk@realtek.com>
 <20161111121311.GA19673@electric-eye.fr.zoreil.com>
 <0835B3720019904CB8F7AA43166CEEB20104EAF8@RTITMBSV03.realtek.com.tw>
 <20161115011044.GA13220@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
        "mlord@pobox.com" <mlord@pobox.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115011044.GA13220@electric-eye.fr.zoreil.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu [mailto:romieu@fr.zoreil.com]
> Sent: Tuesday, November 15, 2016 9:11 AM
[...]
> If it was possible to get it wrong once, it should be possible to
> get it wrong twice, especially if some part of the hardware design
> is recycled. I don't mean anything else.

I agree with you. However, I have to let it could be reproduced
for confirming it.

Besides, the behavior is different for PCIe and USB device. There
is no action of DMA for USB device. It is done by the USB host
controller. And, the USB host controller wouldn't allow the device
sends a data which is more than the size of the buffer.

Best Regards,
Hayes
