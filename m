From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: strange sky disable/enable in the kernel log
Date: Sun, 24 Jun 2007 23:11:20 -0700
Message-ID: <20070624231120.4c04a2ee@freepuppy.localdomain.hemminger.net>
References: <20070622055342.GA11876@dose.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tino Keitel <tino.keitel@tikei.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56647 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752901AbXFYGLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 02:11:44 -0400
In-Reply-To: <20070622055342.GA11876@dose.home.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 22 Jun 2007 07:53:42 +0200
Tino Keitel <tino.keitel@tikei.de> wrote:

> Hi,
> 
> I just found this in the kernel log:
> 
> 2007-06-22_05:47:50.69894 kern.info: sky2 eth0: disabling interface
> 2007-06-22_05:47:50.72039 kern.info: sky2 eth0: enabling interface
> 2007-06-22_05:47:50.72240 kern.info: sky2 eth0: ram buffer 48K
> 2007-06-22_05:47:52.40903 kern.info: sky2 eth0: Link is up at 100 Mbps,
> full duplex, flow control both
> 
> What could be the cause for this? I use kernel 2.6.22-rc5 with this
> hardware:
> 
> sky2 0000:01:00.0: v1.14 addr 0x90200000 irq 17 Yukon-EC (0xb6) rev 2
> 
> 01:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053
> PCI-E Gigabit Ethernet Controller (rev 22)
> 
> Regards,
> Tino

Some  script is calling the device stop (down) call. 
	ifconfig eth0 down
	ip link set eth0 down

another possibility is suspend/resume.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
