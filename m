From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [Patch][IPv6] Fix wrong routing mechanism for Link Local IPv6
 packets
Date: Tue, 30 Jan 2007 17:40:29 +0900 (JST)
Message-ID: <20070130.174029.121638185.yoshfuji@linux-ipv6.org>
References: <1172042666.4512.8.camel@LINE>
	<20070130.162441.39376131.yoshfuji@linux-ipv6.org>
	<024b01c74443$f882d590$ccb1220a@ZhaoleiSOTEC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-users@linux-ipv6.org,
	yoshfuji@linux-ipv6.org
To: weid@np.css.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:47527 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559AbXA3IjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 03:39:13 -0500
In-Reply-To: <024b01c74443$f882d590$ccb1220a@ZhaoleiSOTEC>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <024b01c74443$f882d590$ccb1220a@ZhaoleiSOTEC> (at Tue, 30 Jan 2007 16:55:12 +0900), "Wei Dong" <weid@np.css.fujitsu.com> says:

> Hello, Mr yoshfuji
>     Take ping6 for example. Asumming there is a router which has 2 NICs. 
> eth0 on router has ipv6 addr fe80::20c:29ff:fe24:fa0a, eth1 on router has 
> ipv6 addr fe80::20c:29ff:fe24:fa14. Also there is a host connected to 
> router's eth0, and the host's ipv6 addr is fe80::200:ff:fe00:100. We ping6 
:

I still need more precise figure.

Please draw complete box for the 2-3 boxes (pinger, router (and the
destination)), link(s) and interfaces.

+-------------+
|    Router   |
+---+-----+---+
eth0|     |eth1
    |     |
eth0|    
+---+-+
|Host1|
+-----+

Host1  eth0: fe80:....
Router eth0: fe80:....
Router eth1: fe80:...

Or, something like that....

I think you may use other tool such as tgif etc.

--yoshfuji
