From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: Re: [PATCH v2 0/3] e1000e,igb,ixgbe: add registers etc. printout
 code just before resetting adapters
Date: Thu, 25 Feb 2010 09:30:16 +0900
Message-ID: <4B85C498.2080701@jp.fujitsu.com>
References: <4B593B74.2020601@jp.fujitsu.com>	 <alpine.WNT.2.00.1001221345580.6104@jbrandeb-desk1.amr.corp.intel.com>	 <4B5EC215.5090509@jp.fujitsu.com>	 <alpine.WNT.2.00.1002171043450.5328@jbrandeb-desk1.amr.corp.intel.com>	 <4B7E48F8.7010208@jp.fujitsu.com> <1266578456.25502.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	"chavey@google.com" <chavey@google.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:52101 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758589Ab0BYAa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 19:30:29 -0500
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1P0USRk008466
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Thu, 25 Feb 2010 09:30:28 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7887045DE52
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2010 09:30:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 510C845DE4E
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2010 09:30:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 36FD8E38003
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2010 09:30:28 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CBC2C1DB803B
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2010 09:30:27 +0900 (JST)
In-Reply-To: <1266578456.25502.23.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

> To answer your question, no there are no files you can't submit patches
> to.  We do have some common files which are used/shared amongst all of
> our drivers which are used for initializing and/or bring up the
> hardware, so when a patch is submitted to our drivers which changes our
> "shared code" our first question is "Is this change necessary for all of
> our drivers?" and if the answer is no, then we take a look at what
> changes can be made in the code which is not shared among our other
> drivers.

Please tell me concretely  which part of my former submitted patchset is bad?
Next time I'll create under that condition.

Best regards,
Taku Izumi

