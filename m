From: "Matthieu CASTET" <castet.matthieu@free.fr>
Subject: Re: kernel: TKIP: replay detected:
Date: Mon, 25 Sep 2006 19:13:28 +0000 (UTC)
Message-ID: <ef99oo$4jb$3@sea.gmane.org>
References: <20060924104053.GA6645@frodo.home.lxtec.de>
	<20060925144954.GC16949@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:20947 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1751507AbWIYTP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 15:15:26 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1GRvuw-0005yU-Ix
	for netdev@vger.kernel.org; Mon, 25 Sep 2006 21:15:02 +0200
Received: from cac94-1-81-57-151-96.fbx.proxad.net ([81.57.151.96])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2006 21:15:02 +0200
Received: from castet.matthieu by cac94-1-81-57-151-96.fbx.proxad.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2006 21:15:02 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Mon, 25 Sep 2006 10:50:00 -0400, John W. Linville wrote:

> On Sun, Sep 24, 2006 at 12:40:53PM +0200, Elimar Riesebieter wrote:
> 
>> My sylog is filled up with thousands of:
>> Sep 21 18:18:00 aragorn kernel: TKIP: replay detected: \
>> STA=XX:XX:BB:LL:KK:00 previous TSC 00000000BLAa received TSC 00000000BLAa
>> Sep 21 18:18:29 aragorn kernel: printk: 62 messages suppressed.
> 
> Opinion seems to be running that these messages are useless and should
> be removed.  Anyone disagree?
> 
They could be useful for debugging.

Instead of removing them, enable them when a DEBUG flags is enabled.

Matthieu

