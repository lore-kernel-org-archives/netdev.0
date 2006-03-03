From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [RFC] [PATCH 1/2] Driver to remember ethernet MAC values:
 maclist
Date: Sat, 04 Mar 2006 01:17:47 +0900 (JST)
Message-ID: <20060304.011747.07644094.anemo@mba.ocn.ne.jp>
References: <20060220010113.GA19309@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jbowler@acm.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932212AbWCCQRx@vger.kernel.org>
To: tbm@cyrius.com
In-Reply-To: <20060220010113.GA19309@deprecation.cyrius.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> On Mon, 20 Feb 2006 01:01:13 +0000, Martin Michlmayr <tbm@cyrius.com> said:

tbm> Some Ethernet hardware implementations have no built-in storage
tbm> for allocated MAC values - an example is the Intel IXP420 chip
tbm> which has support for Ethernet but no defined way of storing
tbm> allocated MAC values.  With such hardware different board level
tbm> implementations store the allocated MAC (or MACs) in different
tbm> ways.  Rather than put board level code into a specific Ethernet
tbm> driver this driver provides a generally accessible repository for
tbm> the MACs which can be written by board level code and read by the
tbm> driver.

Slow response:

It can be done with register_netdevice_notifier().  You can catch
NETDEV_REGISTER event, check the device is what you expected by
looking dev->irq or something, and initialize dev->dev_addr.  Whole
these can be implemented in your board level code.

---
Atsushi Nemoto
