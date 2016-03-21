From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH] lan78xx: Protect runtime_auto check by #ifdef CONFIG_PM
Date: Mon, 21 Mar 2016 18:42:06 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D404CC166@CHN-SV-EXMX02.mchp-main.com>
References: <1458581670.9609.5.camel@suse.com>
 <Pine.LNX.4.44L0.1603211415380.1708-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <geert@linux-m68k.org>, <UNGLinuxDriver@microchip.com>,
	<davem@davemloft.net>, <linux@roeck-us.net>, <rjw@rjwysocki.net>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<linux-pm@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <stern@rowland.harvard.edu>, <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1603211415380.1708-100000@iolanthe.rowland.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> But this leaves open the issue that querying the device too often will
> prevent it from going into autosuspend.  It seems to me that the best
> way to deal with this is to make sure that the autosuspend timeout is
> shorter than the interal between queries, not to make the querying
> conditional on !runtime_auto.

Short autosuspend timeout can affect performance. For instance our experiments showed that
shorter than 10sec timeout made Ethernet performance degrade because of wakeup delays.
So, just putting shorter timeout may have some side effects.

Woojung
