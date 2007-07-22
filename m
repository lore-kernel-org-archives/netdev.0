From: Milan Kocian <milon@wq.cz>
Subject: netlink messages on 'ip l s down' event
Date: Sun, 22 Jul 2007 19:30:51 +0200
Message-ID: <1185125451.4376.83.camel@nt.wq.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wq.cz ([82.202.95.52]:49871 "EHLO rd.wq.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756517AbXGVSIx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jul 2007 14:08:53 -0400
Received: from [10.133.1.15]
	by rd.wq.cz with esmtp (Exim 4.67)
	(envelope-from <milon@wq.cz>)
	id 1ICfH2-0007Y0-SI
	for netdev@vger.kernel.org; Sun, 22 Jul 2007 19:31:17 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hello,

I noticed that ipv4 subsystem sends RTM_NEWLINK message with new flags
on 'ip l s down' event, but ipv6 subsystem sends RTM_DELLINK message. Is
it inconsistency or feature? If it is inconsistency, which approach will
be used in future? (tested kernels 2.6.20,21,22)

Thanks for reply.

regards,

-- 
Milan Kocian <milon@wq.cz>

