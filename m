From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Very strange Marvell/Yukon Gigabit NIC networking problems
Date: Tue, 30 Aug 2005 14:05:16 -0700
Message-ID: <20050830140516.316e9695@dxpl.pdx.osdl.net>
References: <20050830133918.42444cae@dxpl.pdx.osdl.net>
	<20050830205027.59306.qmail@web53609.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Daniel Drake <dsd@gentoo.org>, Steve Kieu <haiquy@yahoo.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932474AbVH3VFG@vger.kernel.org>
To: Steve Kieu <haiquy@yahoo.com>
In-Reply-To: <20050830205027.59306.qmail@web53609.mail.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You have a version of the Marvell Yukon that was affected
by a fix in 2.6.13.
	skge addr 0xfeaf8000 irq 19 chip Yukon-Lite rev 9

Both the skge and sk98lin driver were fixed to check for this.
Without the fix, the chip will be in the wrong power mode.

The version of sk98lin driver from SysKonnect already had the
fix, so if your distro used that one, it would have the reset
the power mode as needed.
