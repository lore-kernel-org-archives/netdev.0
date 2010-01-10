From: Vlad Dascalu <vlad.dascalu@goobix.com>
Subject: Fwd: r8169 - Serios Regression (was Re: r8169 linux driver)
Date: Sun, 10 Jan 2010 22:55:23 +0100
Message-ID: <a16d8c9b1001101355x72565562k7c16e5acca243fe4@mail.gmail.com>
References: <a16d8c9b1001101351y1783157r327761bd2c86def1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:21525 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381Ab0AJVzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 16:55:24 -0500
In-Reply-To: <a16d8c9b1001101351y1783157r327761bd2c86def1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Guys,

This is a serios regression which is causing one of my Fedora 12
production server to lose every couple of minutes network connectivity
for 50-60 seconds before coming back.

There are lots of reports and stack dumps at
https://bugzilla.redhat.com/show_bug.cgi?id=538920 . It seems it's
mainly a communication issue to get those dumps on lkml where people
can look at it.

It's still happening with 2.6.31.11 and people report in that bug tons
of versions and stack traces.

I'm mostly clueless when it comes to kernel debugging but if you can
help please take a look.
Thanks!


Original message follows:

List:       linux-netdev
Subject:    Re: r8169 linux driver
From:       David Dillow <dave () thedillows ! org>
Date:       2009-12-04 13:11:24

Added netdev to cc:, where you will get a broader depth of experience.

On Fri, 2009-12-04 at 04:40 -0800, Philip Bordado wrote:
> Did you guys manage to make the r8169 driver work on kernel version >= 2.6.29
> I'm having same problem, the network dies after a few seconds with huge file transfer or nfs transfer.
> I track the irq status but nothing unusual is happening, it just died with no error or nothing.
> So no way to debug :( I load the module using debug=16 as parameter.

I have no problems on anything 2.6.30-rc6 and beyond, but others have
had some issues with infinite loops in the driver that I don't think
were ever fully resolved. However, that doesn't sound like your problem.

It's unclear what kernels you've tried. You seem to imply that you've
tried kernels since 2.6.29, but what's the latest kernel you've tried
and had the issue with?

It will also help if you either send your dmesg output or
dmesg | egrep '(XID|^Linux version)' so that we can see more details
about the hardware.

Dave
