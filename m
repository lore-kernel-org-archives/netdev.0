From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net 2/2] r8152: rx descriptor check
Date: Mon, 14 Nov 2016 06:43:50 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB20104EAF8@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
 <1394712342-15778-228-Taiwan-albertk@realtek.com>
 <20161111121311.GA19673@electric-eye.fr.zoreil.com>
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
In-Reply-To: <20161111121311.GA19673@electric-eye.fr.zoreil.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu [mailto:romieu@fr.zoreil.com]
> Sent: Friday, November 11, 2016 8:13 PM
[...]
> Invalid packet size corrupted receive descriptors in Realtek's device
> reminds of CVE-2009-4537.

Do you mean that the driver would get a packet exceed the size
which is set to RxMaxSize? I check it with our hw engineers.
They don't get any issue about RxMaxSize. And their test for
RxMaxSize register is fine.

> Is the silicium of both devices different enough to prevent the same
> exploit to happen ?

For this case, I don't think the device provide a invalid value
for the receive descriptors. However, the driver sees a different
value. That is why I say the memory is unbelievable.

Best Regards,
Hayes
