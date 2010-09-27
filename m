From: jpo234 <pommnitz@yahoo.com>
Subject: l2tpv3 support not yet in iproute2?
Date: Mon, 27 Sep 2010 15:22:38 +0000 (UTC)
Message-ID: <loom.20100927T170521-559@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:57105 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759697Ab0I0PpQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Sep 2010 11:45:16 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1P0FtD-0003mp-Jl
	for netdev@vger.kernel.org; Mon, 27 Sep 2010 17:45:15 +0200
Received: from proxyext.iabg.de ([proxyext.iabg.de])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 17:45:15 +0200
Received: from pommnitz by proxyext.iabg.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 17:45:15 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,
some time ago James Chapman sent patches that add L2TPv3 support to iproute2:
http://kerneltrap.org/mailarchive/linux-netdev/2010/3/18/6272266/thread
While the kernel support arrived in 2.6.35 the user space configuration support
still seems to be missing:
iproute2-2.6.35$ find . -type f -iname "*.c" | xargs fgrep -i l2tp
doesn't find anything.

Can somebody clarify the current situation?

Thanks in advance
  Joerg

