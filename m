From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: strange inconsistency in printk's
Date: Sat, 17 May 2008 05:53:11 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0805170551290.5409@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, Karsten Keil <kkeil@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from astoria.ccjclearline.com ([64.235.106.9]:37789 "EHLO
	astoria.ccjclearline.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457AbYEQJxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 05:53:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  part of the output from one of my scanning scripts:
...
drivers/net/bsd_comp.c: printk ("<9>ppp: lens_ptr(%d) > max\n", idx);
drivers/net/bsd_comp.c: printk ("<9>ppp: dict_ptr(%d) > max\n", idx);
drivers/isdn/i4l/isdn_bsdcomp.c:                printk (KERN_DEBUG "<9>ppp: lens_ptr(%d) > max\n", idx);
drivers/isdn/i4l/isdn_bsdcomp.c:                printk (KERN_DEBUG "<9>ppp: dict_ptr(%d) > max\n", idx);
...

  is there a reason that a pair of those have a printk level of
KERN_DEBUG while the others don't?  it just looks a bit weird.


rday
--

========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry:
    Have classroom, will lecture.

http://crashcourse.ca                          Waterloo, Ontario, CANADA
========================================================================
