From: Guennadi Liakhovetski <lg@denx.de>
Subject: IPSec in tunnel mode on ARM not working
Date: Sat, 10 Nov 2007 12:57:13 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0711101243590.3320@axis700.grange>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:53822 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751604AbXKJL5J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Nov 2007 06:57:09 -0500
Received: from lyakh (helo=localhost)
	by axis700.grange with local-esmtp (Exim 4.63)
	(envelope-from <g.liakhovetski@gmx.de>)
	id 1Iqoxd-00015j-9A
	for netdev@vger.kernel.org; Sat, 10 Nov 2007 12:57:13 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

Got two setups: with an ARM-based router and with a PC, connecting to 
a remote site using IPSec in tunnel mode over ppp. Setup is identical, 
PC works, ARM router doesn't. Kernel 2.6.23.1.

The setup looks like

PCa --- routerA ==----== routerB --- PCb

where routerA is our problematic router. We issue ping from PCa to PCb, we 
see ICMP packet coming to PCb, being answered, coming back to routerA, and 
there it doesn't get through to PCa. We see it with iptables LOG coming 
into the INPUT chain, and that's about it.

Does anyone haveexperiences with IPSec in tunnel mode on ARM? Or does 
anyone have debugging ideas? Is there a description somewhere how an 
incoming packet traverses the networking stack in such a setup?

Thanks
Guennadi
---
Guennadi Liakhovetski, Ph.D.

DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: +49-8142-66989-0 Fax: +49-8142-66989-80  Email: office@denx.de
