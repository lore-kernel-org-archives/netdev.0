From: Alan Curry <rlwinm@sdf.org>
Subject: Re: PROBLEM: network data corruption (bisected to e5a4b0bb803b)
Date: Tue, 26 Jul 2016 04:32:13 +0000 (UTC)
Message-ID: <201607260432.u6Q4WDae012275@sdf.org>
References: <1659922.nTqITfJpFk@debian64>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
	alexmcwhirter@triadic.us
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1659922.nTqITfJpFk@debian64>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christian Lamparter wrote:
> 
> As for carl9170: I'm not sure what the driver or firmware can do about
> this at this time. You can try to disable the hardware crypto by setting
> nohwcrypt via the module option. However, this might not do anything at all.

The nohwcrypt parameter didn't make any difference.

> > 
> > lsusb identifies my network device as:
> > 
> > Bus 005 Device 004: ID 0cf3:1002 Atheros Communications, Inc. TP-Link TL-WN821N v2 802.11n [Atheros AR9170]
> > 
> > I have version 1.9.9 of carl9170-1.fw in /lib/firmware
> Just one additional question: Is the TL-WN821N connected to a USB3 port?

It never has been before. I tried it today and it made no difference.

-- 
Alan Curry
