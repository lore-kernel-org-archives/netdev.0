From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH] r8152: Add support for setting MAC to system's Auxiliary MAC address
Date: Fri, 3 Jun 2016 09:23:29 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2FED973@RTITMBSV03.realtek.com.tw>
References: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com>
 <20160601230535.GA29279@kroah.com>
 <0bdb98b72b884682b936c0587f965629@ausx13mpc124.AMER.DELL.COM>
 <20160602152244.GA26494@kroah.com>
 <6d9575fd791c4e25b464b9a1b11daa83@ausx13mpc124.AMER.DELL.COM>
 <20160602160902.GA27948@kroah.com>
 <5a22a497af9e467582221cd3a10c90ff@ausx13mpc124.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"pali.rohar@gmail.com" <pali.rohar@gmail.com>,
	"anthony.wong@canonical.com" <anthony.wong@canonical.com>
To: "Mario_Limonciello@Dell.com" <Mario_Limonciello@Dell.com>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5a22a497af9e467582221cd3a10c90ff@ausx13mpc124.AMER.DELL.COM>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mario_Limonciello@Dell.com [mailto:Mario_Limonciello@Dell.com]
> Sent: Friday, June 03, 2016 12:58 AM
[...]
> > Why generate a random one and not just use the one that the network
> > controler already provides?
> 
> That's how the flow works in r8152 already and I'm not overriding it.
> Again, I'll send V2 and you'll see what I did.

The original flows are
1. Read MAC address 1 from device.
2. Check if the MAC address 1 is valid.
3. Use random MAC address if MAC address 1 is invalid.

However, your flow would be
1. Read MAC address 1 from device.
2. Read MAC address 2 from ACPI.
3. Check if the MAC address 2 is valid.
4. Use random MAC address if MAC address 2 is invalid.

Although MAC address 2 may be invalid, MAC address 1 may be valid.
For this situation, you have to use MAC address 1, not random one.

Best Regards,
Hayes
