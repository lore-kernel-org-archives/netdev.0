From: Markus Feldmann <feldmann_markus@gmx.de>
Subject: Re: Daughterboard Jetway JAD3RTLANG with three RTL-8110SC/8169SC
 Gigabit Ethernet is curious
Date: Wed, 07 Dec 2011 11:03:11 +0100
Message-ID: <jbndkv$76p$1@dough.gmane.org>
References: <jb0d7u$bbb$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:36487 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751305Ab1LGKDY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 05:03:24 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1RYELT-0006u4-DA
	for netdev@vger.kernel.org; Wed, 07 Dec 2011 11:03:23 +0100
Received: from dslb-188-096-070-099.pools.arcor-ip.net ([188.96.70.99])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2011 11:03:23 +0100
Received: from feldmann_markus by dslb-188-096-070-099.pools.arcor-ip.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2011 11:03:23 +0100
In-Reply-To: <jb0d7u$bbb$1@dough.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Today i had some problems with the ethernet card at the mid of my 
daughterboard. I tested all 3 ethernet ports more than one time by plug 
in and out the cable again and again. The eth2 made trouble, the orange 
LED blinked slowly. eth1 and eth3 worked correctly (the orange LED 
shined permanently). After some tries with eth2 this ethernet port 
worked at last too.


Here is a output from /var/log/kern.log:
http://pastebin.com/raw.php?i=wtbqMXZd

And /var/log/syslog:
http://pastebin.com/raw.php?i=2tjLWENE

In /var/log/syslog you can see, that only eth2 made trouble, the other 
ports let me connect really fast to my server/router.

regards Markus
