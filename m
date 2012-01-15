From: Vlado Drzik <vlado@ttx.sk>
Subject: ipset 6.x - bitmap:ip,mac not working
Date: Sun, 15 Jan 2012 17:52:26 +0100
Message-ID: <4F13044A.7070900@ttx.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kadlec@blackhole.kfki.hu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ttx02.ttx-net.sk ([193.110.187.3]:49082 "EHLO ttx02.ttx-net.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751482Ab2AORLe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Jan 2012 12:11:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hello All,

Would like to ask whether someone is actually using IP sets in recent
kernel version with bitmap:ip,mac match.
I've updated from ipsets 4.x to ipset 6.10 and kernel 3.1.8 and I've
noticed that bitmap:ip,mac never match.
I've tested also bitmap:ip and that one is working fine.

Test setup:

ipset create ipmac_test bitmap:ip,mac range 172.16.0.0/16
ipset add ipmac_test 172.16.1.254,00:11:22:33:44:55

iptables -I INPUT -i eth0 -m set --match-set ipmac_test src

And after I'm running some communication from host 172.16.1.254 with
source MAC 00:11:22:33:44:55.

But there are not packets matched by the rule in iptables.
Using just bitmap:ip it is working fine. Also previous version 4.x was
working fine with macipmap.

Many thanks.
Regards,
Vladimir Drzik
