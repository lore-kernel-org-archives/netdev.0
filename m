From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: PROBLEM: bug in e1000 module causes very high CPU load
Date: Sat, 10 Dec 2005 14:16:32 -0800
Message-ID: <4807377b0512101416t2f3a04c5ua6859ab3d99e8d07@mail.gmail.com>
References: <20051210114100.QFYF676.mxfep01.bredband.com@ph0x>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965081AbVLJWQe@vger.kernel.org>
To: ph0x <ph0x@freequest.net>
In-Reply-To: <20051210114100.QFYF676.mxfep01.bredband.com@ph0x>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/10/05, ph0x <ph0x@freequest.net> wrote:
> [1.] One line summary of the problem: bug in e1000 (ksoftirqd eats all CPU)
> [2.] Full description of the problem/report:
>
> After a while of using the network (uptime is 15 days now..) it suddenly
> goes below expected performance. Even tho the utilization of the network is
> 2-3MiB/s the CPU load gets unrealisticly high (1.0 - 8.0 in l/a) and the
> system is very unresponsive via ssh. When freshly rebooted, I'm able to get
> 18-19MiB/s without noticing any lag on ssh. Files have been transferred by
> FTP and samba, still the same result. Kernel is freshly compiled
> (http://www.ph0x.org/kernel.config, generated today) and I noticed this
> issue with 2.6.11.2 aswell.
>
> eth0 is a D-Link DFL-530TX (via_rhine) and has no problems using the full
> 100Mbit/s, but the Intel PRO/1000S has problems using over 10Mbit/s. It's
> not related to the computer I transfer to/from, because I've got a gigabit
> laptop aswell which can output much traffic without getting this high load.

please send the output of cat /proc/interrupts, I'm worried you have
an issue due to interrupt sharing.  If it does fail again and is still
usable, please send the output of ethtool -d eth0, and ethtool -S
eth0. Also, is there any chance you can try the 6.2.15 driver from
http://prdownloads.sf.net/e1000

do you have a test to reproduce this?

Thanks, Jesse
