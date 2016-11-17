From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Thu, 17 Nov 2016 03:36:03 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB20105013E@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
 <1394712342-15778-227-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
        "mlord@pobox.com" <mlord@pobox.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-227-Taiwan-albertk@realtek.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[...]
> Fix the hw rx checksum is always enabled, and the user couldn't switch
> it to sw rx checksum.
> 
> Note that the RTL_VER_01 only supports sw rx checksum only. Besides,
> the hw rx checksum for RTL_VER_02 is disabled after
> commit b9a321b48af4 ("r8152: Fix broken RX checksums."). Re-enable it.

Excuse me. If I want to re-send this one patch, should I let
RTL_VER_02 use rx hw checksum?

Best Regards,
Hayes
