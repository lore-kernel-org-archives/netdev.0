From: Markus Feldmann <feldmann_markus@gmx.de>
Subject: iptables NEW or SYN
Date: Thu, 13 May 2010 15:17:32 +0200
Message-ID: <hsgu5c$d8c$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:42358 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752852Ab0EMNRp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 09:17:45 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1OCYIH-0000q3-HX
	for netdev@vger.kernel.org; Thu, 13 May 2010 15:17:41 +0200
Received: from 188.96.72.98 ([188.96.72.98])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 13 May 2010 15:17:41 +0200
Received: from feldmann_markus by 188.96.72.98 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 13 May 2010 15:17:41 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

i am still experiment with iptables and the state extension. Some of my 
rules shall catch packets with the state NEW, but it doesn't catch all 
packets. Sometimes there are packets that have the SYN Flag set which go 
through my rules with the state NEW.

Any idea why?
I thought SYN is included in the state NEW, is that wrong?

What is the difference between SYN and NEW?

regards Markus

