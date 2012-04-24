From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] smsc95xx: mark link down on startup and let PHY
 interrupt deal with carrier changes
Date: Tue, 24 Apr 2012 00:42:40 -0400 (EDT)
Message-ID: <20120424.004240.51699724664176823.davem@davemloft.net>
References: <1335189920-31062-1-git-send-email-paolo.pisati@canonical.com>
	<20120423194339.GS5277@charybde.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paolo.pisati@canonical.com, steve.glendinning@shawell.net,
	netdev@vger.kernel.org
To: fillods@users.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35392 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539Ab2DXEmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 00:42:50 -0400
In-Reply-To: <20120423194339.GS5277@charybde.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephane Fillod <fillods@users.sf.net>
Date: Mon, 23 Apr 2012 21:43:39 +0200

> lun, Apr 23, 2012, Paolo Pisati skribis:
>> Without this patch sysfs reports the cable as present
>> 
>> flag@flag-desktop:~$ cat /sys/class/net/eth0/carrier
>> 1
>> 
>> while it's not:
>> 
>> flag@flag-desktop:~$ sudo mii-tool eth0
>> eth0: no link
>> 
>> Tested on my Beagle XM.
>> 
>> v2: added mantainer to the list of recipient
> 
> His e-mail address has changed, but somehow it has not been updated yet
> in MAINTAINERS directory:  steve.glendinning () shawell.net

Steve, please send a maintainers etc. update and please provide
feedback on this link status fix.
