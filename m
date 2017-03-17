From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] r8152: simply the arguments
Date: Fri, 17 Mar 2017 11:08:05 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFB3ABD@AcuExch.aculab.com>
References: <1394712342-15778-253-Taiwan-albertk@realtek.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFFB29DA@AcuExch.aculab.com>
 <0835B3720019904CB8F7AA43166CEEB201A32FCB@RTITMBSV06.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: 'Hayes Wang' <hayeswang@realtek.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB201A32FCB@RTITMBSV06.realtek.com.tw>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang
> Sent: 17 March 2017 03:00
> To: David Laight; netdev@vger.kernel.org
> Cc: nic_swsd; linux-kernel@vger.kernel.org; linux-usb@vger.kernel.org
> Subject: RE: [PATCH net-next] r8152: simply the arguments
> 
> David Laight [mailto:David.Laight@ACULAB.COM]
> > Sent: Thursday, March 16, 2017 10:28 PM
> [...]
> > If you are really lucky the compiler will optimise it away.
> > Otherwise it will generate another local variable and possibly
> > a register spill to stack.
> 
> However, I could reduce the time for calculating the address,
> because I only calculate it once and save the result to a variable.
> Right?

 address you want is just an offset from another pointer that is
commonly used and ought to be assigned to a register variable.

The offset can be added by the instruction that puts the value into
the register used for the first function argument.

So 'saving' it in another variable is extra work.

	David
