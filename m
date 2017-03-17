From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next] r8152: simply the arguments
Date: Fri, 17 Mar 2017 02:59:42 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB201A32FCB@RTITMBSV06.realtek.com.tw>
References: <1394712342-15778-253-Taiwan-albertk@realtek.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFFB29DA@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFB29DA@AcuExch.aculab.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Laight [mailto:David.Laight@ACULAB.COM]
> Sent: Thursday, March 16, 2017 10:28 PM
[...]
> If you are really lucky the compiler will optimise it away.
> Otherwise it will generate another local variable and possibly
> a register spill to stack.

However, I could reduce the time for calculating the address,
because I only calculate it once and save the result to a variable.
Right?

Best Regards,
Hayes
