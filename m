From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Network failure with 2.6.23-git14
Date: Fri, 19 Oct 2007 12:28:34 -0400
Message-ID: <4718DB32.5000404@garzik.org>
References: <1192790946.6416.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Chris Holvenstot <cholvenstot@comcast.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34725 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755456AbXJSQ2h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 12:28:37 -0400
In-Reply-To: <1192790946.6416.4.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Holvenstot wrote:
> I built 2.6.23-git14 this morning - when booted I can not access the
> network via my Ethernet connection.  Fallback to 2.6.23-git11 works OK.
> One interesting message during boot:

> [   37.325760] forcedeth: Reverse Engineered nForce ethernet driver.
> [   37.843618] forcedeth 0000:00:0a.0: ifname eth0, PHY OUI 0x5043 @ 1,
> addr 00:19:db:6d:3f:1b
> [   37.843623] forcedeth 0000:00:0a.0: highdma csum timirq gbit lnktim
> desc-v3

> [   46.414433] sysfs: duplicate filename 'eth1' can not be created
> [   46.414438] WARNING: at fs/sysfs/dir.c:424 sysfs_add_one()
> [   46.414445]  [<c01ba80f>] sysfs_add_one+0x9f/0xe0
> [   46.414456]  [<c01bb5c6>] sysfs_create_link+0x86/0x110
> [   46.414462]  [<c025608a>] device_rename+0x17a/0x1e0
> [   46.414467]  [<c0130190>] run_timer_softirq+0x30/0x180
> [   46.414472]  [<c0287a60>] dev_change_name+0xb0/0x200
> [   46.414476]  [<c0159a62>] filemap_fault+0x1f2/0x400
> [   46.414478]  [<c012c895>] __do_softirq+0x75/0xf0
> [   46.414484]  [<c027a260>] sock_ioctl+0x0/0x230
> [   46.414487]  [<c028809c>] dev_ioctl+0x25c/0x520
> [   46.414489]  [<c01646eb>] __do_fault+0x1ab/0x380
> [   46.414494]  [<c0165d28>] handle_mm_fault+0xf8/0x610
> [   46.414499]  [<c027a260>] sock_ioctl+0x0/0x230
> [   46.414502]  [<c018343b>] do_ioctl+0x2b/0x90
> [   46.414506]  [<c01834fc>] vfs_ioctl+0x5c/0x290
> [   46.414510]  [<c0183798>] sys_ioctl+0x68/0x80
> [   46.414513]  [<c01041de>] sysenter_past_esp+0x5f/0x85
> [   46.414520]  =======================
> [   46.414523] net eth1: device_rename: sysfs_create_symlink failed


What are your network devices?  Is your problem with eth0, forcedeth, or 
as this traceback implies, eth1?

What is eth1?  (driver, bus, ...)

Can you bisect?

	Jeff



