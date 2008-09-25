From: Tino Keitel <tino.keitel@gmx.de>
Subject: Re: Regression in 2.6.27-rc7: Wake On LAN with sky2 broken
Date: Thu, 25 Sep 2008 21:42:53 +0200
Message-ID: <20080925194253.GA2783@dose.home.local>
References: <20080924080546.GA21108@x61> <200809242113.52256.rjw@sisk.pl> <20080924194906.GA25874@x61> <200809242310.23477.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:44000 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135AbYIYTm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 15:42:56 -0400
Content-Disposition: inline
In-Reply-To: <200809242310.23477.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2008 at 23:10:22 +0200, Rafael J. Wysocki wrote:

[...]

> Can you try:
> 
> # ethtool -s eth0 wol g
> # echo devices > /sys/power/pm_test
> # echo mem > /sys/power/state
> (this should wait for 5 seconds and return to the command line)
> 
> and see if the machine hangs during this operation?

It didn't hang. The dmesg output from the suspend attempt is here:

http://tikei.de/dmesg_suspend

> 
> Please also attach the boot log from your system.

dmesg output after boot:

http://tikei.de/dmesg

Regards,
Tino
