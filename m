From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] bonding: add the debugfs facility to the bonding
 driver
Date: Mon, 13 Dec 2010 14:09:30 +0900
Message-ID: <4D05AA8A.8020705@jp.fujitsu.com>
References: <4CF89A6E.4090303@jp.fujitsu.com>	<4D017F99.2040706@jp.fujitsu.com>	<29210.1292026905@death> <20101210.162319.35837953.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org, eric.dumazet@gmail.com,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:59271 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781Ab0LMFJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 00:09:40 -0500
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBD59cBa021281
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Mon, 13 Dec 2010 14:09:38 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4ACAE45DE5B
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 14:09:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 31B4845DE4D
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 14:09:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D25BE08003
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 14:09:38 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DCFA11DB803C
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 14:09:37 +0900 (JST)
In-Reply-To: <20101210.162319.35837953.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(2010/12/11 9:23), David Miller wrote:
> From: Jay Vosburgh<fubar@us.ibm.com>
> Date: Fri, 10 Dec 2010 16:21:45 -0800
> 
>> Taku Izumi<izumi.taku@jp.fujitsu.com>  wrote:
>>
>>>
>>> This patch provides the debugfs facility to the bonding driver.
>>> The "bonding" directory is created in the debugfs root and directories of
>>> each bonding interface (like bond0, bond1...) are created in that.
>>>
>>> # mount -t debugfs none /sys/kernel/debug
>>>
>>> # ls /sys/kernel/debug/bonding
>>> bond0  bond1
>>>
>>> Signed-off-by: Taku Izumi<izumi.taku@jp.fujitsu.com>
>>
>> 	Tested replacement patch 1 with original patches 2 and 3.  Works
>> as advertised, no pesky crashes.
>>
>> Signed-off-by: Jay Vosburgh<fubar@us.ibm.com>
> 
> I'll apply this patch #1.  Taku-san, could you please report patch #2
> and #3 and remember to include Jay's signoff.
> 

 I resent the patch #2 and #3 with Jay's signoff.

Best regards,
Taku Izumi


