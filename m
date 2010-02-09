From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: bluetooth-2.6 2010-02-05
Date: Mon, 08 Feb 2010 22:50:11 -0800 (PST)
Message-ID: <20100208.225011.23377444.davem@davemloft.net>
References: <cover.1265399549.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59810
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751457Ab0BIGt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 01:49:57 -0500
In-Reply-To: <cover.1265399549.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Fri,  5 Feb 2010 12:05:33 -0800

> here are a few more fixes that are mostly a result from the Bluetooth
> UnPlugFest testing in Seattle during this week.

Man, I live in Seattle and I still never get invited to these
cool events ;-)

> The important one are the fix for the sleeping function call in the
> RFCOMM timer that show up with certain hardware (not all of them) and
> also the fix for double release of the underlaying L2CAP session.
> 
> With the HID subsystem changes that turns it into a proper bus, the
> HIDP code ended up with a potential case where we access userspace
> memory out of the scop of its ioctl() command. Fix this by just keeping
> a copy of the HID report descriptor around. The HID subsystem will need
> that anyway.
> 
> The rest are some SCO/eSCO audio setup fixes with broken hardware and
> closing a memory leak in the Marvell driver.
 ...
> Please pull from
> 
>     git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master

Pulled, thanks!
