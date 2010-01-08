From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] igb: add registers etc. printout code just before
 	resetting adapters
Date: Fri, 08 Jan 2010 19:33:15 +0900
Message-ID: <4B4709EB.4080205@jp.fujitsu.com>
References: <4B45BBA5.8010407@jp.fujitsu.com> <4B45BF26.3020600@jp.fujitsu.com> <97949e3e1001071116m3ffc8734p5285e16bcdb7b468@mail.gmail.com>
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
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
To: Laurent Chavey <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:57638 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944Ab0AHKdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 05:33:32 -0500
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o08AXUxm014042
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Fri, 8 Jan 2010 19:33:30 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F12B45DE51
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2010 19:33:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 50F2C45DE4F
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2010 19:33:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A8031DB8038
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2010 19:33:30 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EAC871DB803B
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2010 19:33:29 +0900 (JST)
In-Reply-To: <97949e3e1001071116m3ffc8734p5285e16bcdb7b468@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(2010/01/08 4:16), Laurent Chavey wrote:
> since hexdump() is already in patch 1/3, could this be moved
> to lib/hexdump.c (or could the code make use of hex_dump_to_buffer())
> 
> same comment as for patch1/3 for the call to igb_dump()
> [use of dump_flag] I can see how it the flag is use thru out the
> call but did not see how it prevents the  logging of netdev
> info.
> 
> it looks like the code in each of the case statement is identical
> except for some naming. Could this be converted to
> a data driven table (register definition, type, dump routine.)
> The later may actually be leveraged across drivers and
> use full to implement some semi standard debug dump
> reg tool.

 Thank you for your useful comment. I'll reflect your comment and
 improve later.


Best regards,
Taku Izumi

