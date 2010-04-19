From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v3 0/3] e1000e,igb,ixgbe: add registers etc. printout code
 just before resetting adapters
Date: Mon, 19 Apr 2010 20:20:59 +0900
Message-ID: <4BCC3C9B.3000901@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, chavey@google.com
To: Bruce Allan <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"Kirsher, Jeffre
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:51476 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753580Ab0DSLV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 07:21:27 -0400
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3JBLPdR024409
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Mon, 19 Apr 2010 20:21:26 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B606A45DE4F
	for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 20:21:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D35F45DE4C
	for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 20:21:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 798C61DB8015
	for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 20:21:25 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CA731DB8014
	for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 20:21:25 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

This patchset is the update version of "register etc. printout code" patch.
The old ones are
 http://kerneltrap.org/mailarchive/linux-netdev/2010/1/7/6265865
 http://kerneltrap.org/mailarchive/linux-netdev/2010/1/22/6267176

v2 -> v3:
 - avoid modifying headers
 - delete "dump_flag" module parameter and use msglvl instead.

 To enable the printout, it is necessary to specify msglvl like the following.
 #	 ethtool -s eth0 msglvl 0x2003

Best regards,
Taku Izumi

