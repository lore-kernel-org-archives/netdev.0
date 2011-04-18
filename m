From: Joe Buehler <aspam@cox.net>
Subject: DSCP values in TCP handshake
Date: Mon, 18 Apr 2011 13:48:53 +0000 (UTC)
Message-ID: <loom.20110418T154445-102@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:56658 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752995Ab1DRNtM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 09:49:12 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1QBopD-0000ez-Fj
	for netdev@vger.kernel.org; Mon, 18 Apr 2011 15:49:11 +0200
Received: from netrokpix001.spirentcom.com ([96.241.21.98])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2011 15:49:11 +0200
Received: from aspam by netrokpix001.spirentcom.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2011 15:49:11 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What does the LINUX network code put in the DSCP field of TCP SYN-ACK packets
that are replies to a SYN connection request?  I have a customer sending SYN
with 0x2e in the DSCP field but apparently getting DSCP 0x0 in the reply.

Joe Buehler


