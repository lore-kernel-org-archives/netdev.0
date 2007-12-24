From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: iproute2 action ipt + iptables 1.4.0
Date: Mon, 24 Dec 2007 11:31:18 +0200
Message-ID: <20071224090622.M86562@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:49867 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbXLXJbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 04:31:31 -0500
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id 5CD1ABC7B9
	for <netdev@vger.kernel.org>; Mon, 24 Dec 2007 11:31:18 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seems latest iproute2(even from GIT) searching for libipt_MARK (for example),
while it is libxt_MARK.

Even if i correct names it will be still not functional
"undefined symbol: xtables_register_target"

Probably some other issues actual with new version of iptables libraries?



--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

