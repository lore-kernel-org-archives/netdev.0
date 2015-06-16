From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Fw: [Bug 98781] New: WWAN: TX bytes counter shows very huge
 impossible value
Date: Tue, 16 Jun 2015 09:04:54 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB507B2@AcuExch.aculab.com>
References: <20150526083857.78cb053b@urahara>
 <loom.20150613T021828-603@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Kevin' <kevin.padoa@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.185]:53819 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932705AbbFPJGw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 05:06:52 -0400
In-Reply-To: <loom.20150613T021828-603@post.gmane.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin
> Sent: 13 June 2015 01:29
...
> Linux uranis 3.19.0-20-generic #20-Ubuntu SMP Fri May 29 10:10:47 UTC 2015
> x86_64 x86_64 x86_64 GNU/Linux
> 
> wwan0     Link encap:Ethernet  HWaddr 26:03:a9:e3:88:2e
>           inet addr:41.150.225.132  Bcast:41.150.225.135  Mask:255.255.255.248
>           inet6 addr: fe80::2403:a9ff:fee3:882e/64 Scope:Link
>           UP BROADCAST RUNNING NOARP MULTICAST  MTU:1500  Metric:1
>           RX packets:3366 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:3497 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:1459963 (1.4 MB)  TX bytes:15019500985395 (15.0 TB)
> 
> Kernel internal or module (driver) bug, shows up everywhere including
> 'system monitor'. This problem has come up a few years back and was solved,
> but seems to be back again...
> 
> Any ideas on fix ?

$ printf '%x\n' 15019500985395
da900055c33
$ echo $((0xda9))
3497
$ echo $((0x55c33))
351283

Looks like a 32-64bit fubar somewhere.

	David
