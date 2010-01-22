From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: Re: [PATCH v2 0/3] e1000e,igb,ixgbe: add registers etc. printout
 code just before resetting adapters
Date: Fri, 22 Jan 2010 17:46:30 +0900
Message-ID: <4B5965E6.8090109@jp.fujitsu.com>
References: <4B593B74.2020601@jp.fujitsu.com> <1264141501.32383.75.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	chavey@google.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:56472 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112Ab0AVIqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 03:46:49 -0500
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0M8kmuh028717
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Fri, 22 Jan 2010 17:46:48 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5514B45DE4F
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 17:46:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 324B745DE50
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 17:46:47 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C7D91DB8037
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 17:46:47 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B46BE08002
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 17:46:46 +0900 (JST)
In-Reply-To: <1264141501.32383.75.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(2010/01/22 15:25), Joe Perches wrote:
> Trivial:
> 
> All of the printks without KERN_<level>  should be KERN_CONT
> 
> For example:
> 
>> +	printk(KERN_ERR "%-15s ", rname);
>> +	for (n = 0; n<  2; n++)
>> +		printk("%08x ", __er32(hw, get_regofs(n)));
>> +	printk("\n");
> 
> This should be:
> 
> 	printk(KERN_ERR etc...)
> 	for (n = 0...)
> 		printk(KERN_CONT "%08x ", etc...
> 	printk(KERN_CONT "\n")
> 
> or perhaps written without the for loop
> 
> 	printk(KERN_ERR "%-15s %08x %08x\n",
> 	       name, __er32(hw, get_regofs(0)), __er32(hw, get_regofs(1)));
> 

Thank you for good information! I didn't realize that.
I'll rewrite all.

Best regards,
Taku Izumi

