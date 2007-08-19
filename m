From: Kevin E <kevin360@yahoo.com>
Subject: Re: Marvell 88E8056 gigabit ethernet controller
Date: Sun, 19 Aug 2007 12:13:57 -0700 (PDT)
Message-ID: <551158.43737.qm@web38907.mail.mud.yahoo.com>
References: <20070819113400.12f5570c@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755920AbXHSTOO@vger.kernel.org>
In-Reply-To: <20070819113400.12f5570c@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Stephen Hemminger
<shemminger@linux-foundation.org> wrote:

> The driver prints some chip version info at startup,
> that might
> be helpful in disambiguating good/bad versions:
> 
> 	dmesg | grep sky2

Here's the output from the working MB:

sky2 0000:04:00.0: v1.14 addr 0xf8000000 irq 16
Yukon-EC Ultra (0xb4) rev 3
sky2 eth0: addr 00:1a:4d:42:61:46
sky2 eth0: enabling interface
sky2 eth0: ram buffer 0K
sky2 eth0: Link is up at 100 Mbps, full duplex, flow
control both

The broken MB there's no output in dmesg but there is
in /var/log/messages (I just rebooted the machine to
get the output):

Aug 19 14:56:42 www kernel: sky2 0000:04:00.0: v1.14
addr 0xf8000000 irq 16 Yukon-EC Ultra (0xb4) rev 3
Aug 19 14:56:42 www kernel: sky2 eth1: addr
00:1a:4d:82:11:02




       
____________________________________________________________________________________
Moody friends. Drama queens. Your life? Nope! - their life, your story. Play Sims Stories at Yahoo! Games.
http://sims.yahoo.com/  
