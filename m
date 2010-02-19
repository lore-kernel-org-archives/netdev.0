From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: Re: [PATCH v2 0/3] e1000e,igb,ixgbe: add registers etc. printout
 code just before resetting adapters
Date: Fri, 19 Feb 2010 17:16:56 +0900
Message-ID: <4B7E48F8.7010208@jp.fujitsu.com>
References: <4B593B74.2020601@jp.fujitsu.com> <alpine.WNT.2.00.1001221345580.6104@jbrandeb-desk1.amr.corp.intel.com> <4B5EC215.5090509@jp.fujitsu.com> <alpine.WNT.2.00.1002171043450.5328@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	"chavey@google.com" <chavey@google.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:42462 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754810Ab0BSIRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 03:17:15 -0500
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1J8HDwJ019225
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Fri, 19 Feb 2010 17:17:14 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BA6B945DE57
	for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 17:17:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F32F45DE54
	for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 17:17:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1174FE1800A
	for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 17:17:13 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B6F2EE18004
	for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 17:17:12 +0900 (JST)
In-Reply-To: <alpine.WNT.2.00.1002171043450.5328@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesse,

> I have a counter proposal to make, here is a (incomplete) patch that we
> use all the time to debug tx hangs.  This example is for e1000e.  We are
> trying to avoid changes with other users' copyright to some of the files
> in our drivers so that we can ship them under multiple license.  We would
> much prefer something like this to be used, can you review?

  I haven't understood yet about the reason we have to avoid changing some
  files. Are there any files (header files?) we can't modify?

Best regards,
Taku Izumi

