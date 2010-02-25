From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: Re: [PATCH v2 0/3] e1000e,igb,ixgbe: add registers etc. printout
 code 	just before resetting adapters
Date: Thu, 25 Feb 2010 09:24:54 +0900
Message-ID: <4B85C356.9090703@jp.fujitsu.com>
References: <4B593B74.2020601@jp.fujitsu.com> <alpine.WNT.2.00.1001221345580.6104@jbrandeb-desk1.amr.corp.intel.com> 	<4B5EC215.5090509@jp.fujitsu.com> <alpine.WNT.2.00.1002171043450.5328@jbrandeb-desk1.amr.corp.intel.com> 	<4B7E48F8.7010208@jp.fujitsu.com> <1266578456.25502.23.camel@localhost.localdomain> <97949e3e1002241136q70f55c97rafd79c2a5a19349c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Laurent Chavey <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:51861 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758572Ab0BYAZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 19:25:25 -0500
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1P0PMn0006061
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Thu, 25 Feb 2010 09:25:22 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B2FB45DE79
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2010 09:25:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 19AE545DE60
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2010 09:25:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EB3B01DB803E
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2010 09:25:21 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9893F1DB803A
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2010 09:25:21 +0900 (JST)
In-Reply-To: <97949e3e1002241136q70f55c97rafd79c2a5a19349c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chavey,

> I like the idea of adding debugging support. While using syslog does provide
> a "easier" way to get the output out, I am wondering if it would be
> worse the while
> to try to add a generic debug interface (via ethtool / netlink) that
> each driver would
> then support.
> 
> If using syslog is the choosen way, then having the feature on by
> default may not
> be wanted.

I think these pritout messages are not only for debugging purpose but
a kind of error notification, for adapter resetting is error.
I prefer that these messages are always output wheter debugging mode is enabled
or not, but if it is not hoped to be always output to syslog, another place
(like a private ring buffer) is also acceptable.
Now I'm considering to output to private pring buffer.

Taku Izumi

