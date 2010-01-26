From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: Re: [PATCH v2 0/3] e1000e,igb,ixgbe: add registers etc. printout
 code just before resetting adapters
Date: Tue, 26 Jan 2010 19:21:09 +0900
Message-ID: <4B5EC215.5090509@jp.fujitsu.com>
References: <4B593B74.2020601@jp.fujitsu.com> <alpine.WNT.2.00.1001221345580.6104@jbrandeb-desk1.amr.corp.intel.com>
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
	e1000-devel@lists.sourceforge.net
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:37839 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754Ab0AZKV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 05:21:28 -0500
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0QALR9U008516
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Tue, 26 Jan 2010 19:21:27 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D5CA45DE60
	for <netdev@vger.kernel.org>; Tue, 26 Jan 2010 19:21:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A3BD45DE4D
	for <netdev@vger.kernel.org>; Tue, 26 Jan 2010 19:21:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EF4AF1DB803A
	for <netdev@vger.kernel.org>; Tue, 26 Jan 2010 19:21:26 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A62361DB8037
	for <netdev@vger.kernel.org>; Tue, 26 Jan 2010 19:21:26 +0900 (JST)
In-Reply-To: <alpine.WNT.2.00.1001221345580.6104@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesse,

(2010/01/23 6:54), Brandeburg, Jesse wrote:
> Taku, thanks for these, we are talking the patches over and reviewing
> them.  While I agree with the idea of these patches is good, I still don't
> agree with the default being enabled.  Usually if someone is getting tx
> hangs they are repeatable and we can work with them to get the debug
> turned on.  I DO think it is useful to have the feature available by
> default but NOT enabled.
> 
> If we wanted to enable something by default it might be useful to print
> something that actually draws some conclusions from known failure modes,
> like if TDH!=TDT after some amount of time.  I think one or two lines
> maximum for default printing.
> 
> If you're working in this area I had an idea.  I had wanted to be able to
> print the large amount of ring information (especially in the ixgbe case
> with many rings) to the ftrace buffers in order to not overrun the syslog
> daemon.  Not sure if you're interested in more new features, it certainly
> is separate but related to this patch.

I thought similar things, that is, all information should be dumped to
the private ring buffer to avoid filling syslog up with driver messages.
But I didn't have any good idea to extract information from ring buffers,
so as the first step, I decided to printout it by using printk().
Is there the easy way to extract it from ring buffers?

Best regards,
Taku Izumi

