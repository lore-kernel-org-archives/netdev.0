From: Dave Jones <davej@redhat.com>
Subject: sch_generic warn_on (timed out)
Date: Mon, 11 Jul 2011 16:48:34 -0400
Message-ID: <20110711204834.GA4950@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3233 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753165Ab1GKUsh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 16:48:37 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p6BKmar3018298
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2011 16:48:36 -0400
Received: from gelk.kernelslacker.org (ovpn-113-98.phx2.redhat.com [10.3.113.98])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p6BKmZeQ001440
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2011 16:48:36 -0400
Received: from gelk.kernelslacker.org (gelk [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.4) with ESMTP id p6BKmZjx005950
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2011 16:48:35 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id p6BKmYW1005949
	for netdev@vger.kernel.org; Mon, 11 Jul 2011 16:48:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We've recieved quite a few bug reports in Fedora recently concerning this warning in
sch_generic..

            WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit queue %u timed out\n",
                      dev->name, netdev_drivername(dev, drivername, 64), i);

https://bugzilla.redhat.com/show_bug.cgi?id=702723 is our 'master bug' that we're
duping all others against. It seems to be showing up on a variety of different
hardware (r8169, atl1c, ipheth, e1000e, 8139too). Do all these drivers need
fixing ? or is it just 'crap hardware' ?

note that I've only been looking through fedora 15 bugs so far (which is still on 2.6.38),
but looking at the commit log for sch_generic, it doesn't seem that there's anything
obvious that needs backporting.

thanks,

	Dave
