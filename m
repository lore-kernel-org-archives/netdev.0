From: Bert Vermeulen <bert@biot.com>
Subject: bridge/brctl/ip
Date: Sat, 2 Apr 2016 21:26:55 +0200
Message-ID: <57001CFF.20508@biot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kiutl.biot.com ([31.172.244.210]:44984 "EHLO kiutl.biot.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750972AbcDBTrT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Apr 2016 15:47:19 -0400
Received: from spamd by kiutl.biot.com with sa-checked (Exim 4.83)
	(envelope-from <bert@biot.com>)
	id 1amRCE-0005lv-3v
	for netdev@vger.kernel.org; Sat, 02 Apr 2016 21:26:58 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I'm wondering about the current userspace toolset to control bridging in
the Linux kernel. As far as I can determine, functionality is a bit
scattered right now between the iproute2 (ip, bridge) and bridge-utils
(brctl) tools:

- creating/deleting bridges: ip or brctl
- adding/deleting ports to/from bridge: brctl only
- showing bridge fdb: brctl (in-kernel fdb), bridge (hardware offloaded
  fdb) (!)
...and no doubt a few other things.

Also the brctl tool seems not to be getting updates, whereas the
iproute2 tools are of course updated regularly. Is brctl considered
obsolete?

If that is the case, would patches to add the missing functionality into
the bridge tool be welcome? I'm thinking primarily of creating/deleting
bridges, and adding/deleting ports in bridges.


-- 
Bert Vermeulen
bert@biot.com
