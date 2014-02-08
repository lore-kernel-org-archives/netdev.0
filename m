From: Thomas Glanzmann <thomas@glanzmann.de>
Subject: Re: REGRESSION f54b311142a92ea2e42598e347b84e1655caf8e3 tcp auto
 corking slows down iSCSI file system creation by factor of 70 [WAS: 4 TB
 VMFS creation takes 15 minutes vs 26 seconds]
Date: Sat, 8 Feb 2014 14:58:38 +0100
Message-ID: <20140208135838.GC20512@glanzmann.de>
References: <20140206153640.GB4103@glanzmann.de>
 <1391727771.14985.41.camel@haakon3.risingtidesystems.com>
 <20140207051500.GB10916@glanzmann.de>
 <20140207075536.GB17815@glanzmann.de>
 <1391801597.1155.28.camel@haakon3.risingtidesystems.com>
 <20140207205142.GA8609@glanzmann.de>
 <20140208093808.GD16336@glanzmann.de>
 <1391865273.10160.76.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140208133744.GA20512@glanzmann.de>
 <1391867614.10160.89.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Ogness <john.ogness@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	target-devel <target-devel@vger.kernel.org>,
	Linux Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1391867614.10160.89.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Eric,

> What is your NIC model and driver?

I have four Intel Corporation I350 Gigabit Network Connection (rev 01).

(node-62) [~/work/linux-2.6] lspci -v | pbot
http://pbot.rmdir.de/rgu6yHMBDVQpflMmbcJACg
(node-62) [~/work/linux-2.6] ip a s | pbot
http://pbot.rmdir.de/xJjRT8u-ekC6mrWgl09ZtQ
(node-62) [~/work/linux-2.6] dmesg | pbot
http://pbot.rmdir.de/MigrSPtxGmp0fI1CRgXsHw

I do 802.3ad link aggregation layer 2 hash with two network cards to one
switch.

I'm running:
Linux node-62 3.14.0-rc1+ #23 SMP Sat Feb 8 14:27:47 CET 2014 x86_64 GNU/Linux

Driver: igb

If you need remote access to the machine let me know.

Cheers,
        Thomas
