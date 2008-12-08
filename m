From: Hitoshi Mitake <mitake@clustcom.com>
Subject: [RFC] New functions to manipulate registers for ethtool
Date: Mon, 8 Dec 2008 17:12:30 +0900
Message-ID: <20081208171230.288c5ccf.mitake@clustcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ktaka@clustcom.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752892AbYLHIMv@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi

I want to add two new functions to ethtool.

One is for setting driver's registers on MMIO area like --change-eeprom option.
I think form of command line is like this,
ethtool -X|--set-register ethX [offset N(in bytes)] [value N(single byte value)]

Another function is for reading driver's register on MMIO.
Currently, there is --register-dump option for dumping registers.
But I want finer granularity one which unit of manipulation is byte.
Like this,
ethtool -B|--dump-register-byte ethX [offset N(in bytes)]
(then print one byte to stdout)

Of course, names of options is temporary.

Because e1000e driver conflicts with some IPMI cards some time,
and the reasons of conflict are setting of registers not supported by
other general options of ethtool.
If this function is added, examing cause of confliction will be much easier.

How do you think about this plan?
If this plan is not bad, and nobody is working on patch like this plan,
I want to do that.

Thanks

Hitoshi
