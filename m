From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] bonding: add the debugfs facility to the bonding
 driver
Date: Fri, 10 Dec 2010 16:23:19 -0800 (PST)
Message-ID: <20101210.162319.35837953.davem@davemloft.net>
References: <4CF89A6E.4090303@jp.fujitsu.com>
	<4D017F99.2040706@jp.fujitsu.com>
	<29210.1292026905@death>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: izumi.taku@jp.fujitsu.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34764
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757234Ab0LKAWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 19:22:51 -0500
In-Reply-To: <29210.1292026905@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 10 Dec 2010 16:21:45 -0800

> Taku Izumi <izumi.taku@jp.fujitsu.com> wrote:
> 
>>
>>This patch provides the debugfs facility to the bonding driver.
>>The "bonding" directory is created in the debugfs root and directories of
>>each bonding interface (like bond0, bond1...) are created in that.
>>
>> # mount -t debugfs none /sys/kernel/debug
>>
>> # ls /sys/kernel/debug/bonding
>> bond0  bond1
>>
>>Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
> 
> 	Tested replacement patch 1 with original patches 2 and 3.  Works
> as advertised, no pesky crashes.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

I'll apply this patch #1.  Taku-san, could you please report patch #2
and #3 and remember to include Jay's signoff.

Thanks.
