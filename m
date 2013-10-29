From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] r8152 bug fixes
Date: Tue, 29 Oct 2013 00:23:17 -0400 (EDT)
Message-ID: <20131029.002317.345164763391263319.davem@davemloft.net>
References: <1382961494-2272-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382961494-2272-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Mon, 28 Oct 2013 19:58:09 +0800

> These could fix some driver issues.
> 
> Hayes Wang (5):
>   net/usb/r8152: fix tx/rx memory overflow
>   net/usb/r8152: make sure the tx checksum setting is correct
>   net/usb/r8152: modify the tx flow
>   net/usb/r8152: fix incorrect type in assignment
>   net/usb/r8152: code adjust

These are not bug fixes, some of them are just cleanups.

It is inappropriate to mix real bug fixes and non-bug fixes into
a patch series.

You must send purely the bug fixes for 'net' tree, and then later
the code cleanups and other changes targetting the 'net-next' tree.

Also, from patch #5:

====================
 -Something else
====================

That is completely unacceptable.  You must say what changes you are
making, the above says nothing to me nor the person reading your
commit messages in the future.

In general, your commit messages are poorly written in that they
contain not enough information for the person trying to understand
your patches at all.
