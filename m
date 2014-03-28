From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 0/4] Provide netdev naming-policy via sysfs
Date: Fri, 28 Mar 2014 14:54:10 -0400 (EDT)
Message-ID: <20140328.145410.1817326821928803131.davem@davemloft.net>
References: <1395839117-20090-1-git-send-email-dh.herrmann@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, teg@jklm.no, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: dh.herrmann@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395839117-20090-1-git-send-email-dh.herrmann@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Herrmann <dh.herrmann@gmail.com>
Date: Wed, 26 Mar 2014 14:05:13 +0100

> The main use-case is to allow udev to skip applying reliable ifnames to virtual
> devices. For instance, if wifi-P2P devices are created, wpas already provides a
> suitable naming-policy and udev shouldn't touch these devices. Same is true for
> other virtual devices.

This makes no sense at all.

If udev should avoid applying names to wifi-P2P devices, that policy can
be instituted completely inside of udev.  There is no need whatsoever
for kernel support.

udev can look at the device type, and policies can be defined that key
off of that device type, entirely in userspace.

I'm not applying this patch series, sorry.
