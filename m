From: kuznet@ms2.inr.ac.ru
Subject: Re: "new style" netdevice allocation patch for TUN driver (2.4.18 kernel)
Date: Thu, 1 Aug 2002 22:01:37 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208011801.WAA07242@sex.inr.ac.ru>
References: <20020801175204.GC17308@nic.nigdzie>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: jajcus@bnet.pl (Jacek Konieczny)
In-Reply-To: <20020801175204.GC17308@nic.nigdzie> from "Jacek Konieczny" at Aug 1, 2 07:52:06 pm
List-Id: netdev.vger.kernel.org

Hello!

> but finally it is finished. On system shutdown, when all routes are
> removed, all interfaces downed and all processes killed the device will
> not be used any more and the device is freed.

I do not understand this. It is leak and we have to find who continues
to use the device.


> And even if there is a bug

Nope. The bug is the first, the cleanup is the second.

Alexey
