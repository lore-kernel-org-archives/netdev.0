From: Nadia Derbey <Nadia.Derbey@bull.net>
Subject: [IPROUTE] compilation problem
Date: Thu, 15 Mar 2007 13:55:36 +0100
Message-ID: <45F94248.4080003@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:43426 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030194AbXCOMwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2007 08:52:14 -0400
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 4AB8719D971
	for <netdev@vger.kernel.org>; Thu, 15 Mar 2007 13:52:05 +0100 (CET)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 03760-08 for <netdev@vger.kernel.org>;
 Thu, 15 Mar 2007 13:52:03 +0100 (CET)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 0D3B219D92A
	for <netdev@vger.kernel.org>; Thu, 15 Mar 2007 13:52:03 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Trying to compile iproute2 (downloaded from 
http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.20-070313.tar.gz) 
I get the following error message.

gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../include 
-DRESOLVE_HOSTNAMES -DCONFIG_GACT -DCONFIG_GACT_PROB   -c -o m_ipt.o m_ipt.c
In file included from ../include/libiptc/libiptc.h:6,
                  from ../include/iptables.h:5,
                  from m_ipt.c:17:
../include/linux/netfilter_ipv4/ip_tables.h:115:39: error: 
linux/netfilter/xt_tcpudp.h: No such file or directory
make[1]: *** [m_ipt.o] Error 1
rm emp_ematch.lex.c emp_ematch.yacc.c
make[1]: Leaving directory `/home/lkernel/src/iproute-2.6.20-070313/tc'



This error goes away when I copy xt_tcpudp.h from the linux kernel tree 
(include/linux/netfilter) to the the private iproute include directory.

Am I doing something wrong?

Please Cc me since I'm not subscribed.

Regards,
Nadia


