From: Meelis Roos <mroos@linux.ee>
Subject: ipv4 conntrack module loading broken?
Date: Thu, 26 Jul 2007 20:49:49 +0300 (EEST)
Message-ID: <Pine.SOC.4.64.0707262045300.1921@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:54230 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763298AbXGZSYw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2007 14:24:52 -0400
Received: from math.ut.ee (math.ut.ee [193.40.36.2])
	by smtp2.it.da.ut.ee (Postfix) with ESMTP id A6E104C03669
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 20:49:49 +0300 (EEST)
Received: from localhost (localhost [127.0.0.1])
	by math.ut.ee (Postfix) with ESMTP id 918656ADEB
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 20:49:49 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I tested 2.6.23-rc1 on my prep (arch=ppc) NAT firewall. iptables loaded 
rules fine (simplest test was with single SNAT rule in POSTROUTING chain 
in nat table) and iptables -L showed the rule was loaded. But no packets 
matched the rule and traffic passed un-NATed (just routed). Adding LOG 
rules showed that no packets reach POSTROUTING at all - and no packets 
read PREROUTING (didn't test more).

However, after loading nf_conntrack_ipv4 module by hand, the existing 
rules started working.

Is autoloading of nf_conntrack_ipv4 broken?

-- 
Meelis Roos (mroos@linux.ee)
