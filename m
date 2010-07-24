From: Marc Haber <mh+linux-kernel@zugschlus.de>
Subject: e1000e crashes with 2.6.34.x and ThinkPad T60
Date: Sat, 24 Jul 2010 11:26:44 +0200
Message-ID: <20100724092644.GA13353@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have a new notebook, a Thinkpad T60, which is freezing in random
intervals (like 30 minutes to two days) as long as I am using the
on-board wired ethernet interface, which is an e1000e, [8086:109a]. As
long as I keep using the WLAN, the system runs for weeks despite
frequent suspend/resume cycles etc. The crashes seem really to be tied
to using the wired ethernet. This is a hard freeze, with nothing
happening on the system, only a long push on the power button helps.

Additionally, sometimes, probably after suspend/resume, the wired
ethernet does not come up properly again, ip addr claims "NO CARRIER"
even if the LEDs on the interface and on the switch claim that there
was a link. No packets are received by the interface when it's at this
stage.

Both issues appear with 2.6.34 and 2.6.34.1. I didn't try any of these
issues with an older kernel, 2.6.34 was already out when I started
using the T60.

To rule out defective hardware, I have tried with a second T60, with
the same results.

Full dmesg and lspci-nn attached, please say if you need more.

Greetings
Marc

P.S.: Please Cc: me on replies, both linux-kernel and netdev are too
big for me to timely follow. I am subscribed to both lists, but a Cc
helps in getting a faster reply.

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
