From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6.17-rc6-mm1 ] net: RFC 3828-compliant UDP-Lite
 support
Date: Fri, 09 Jun 2006 22:29:15 +0900 (JST)
Message-ID: <20060609.222915.60108698.yoshfuji@linux-ipv6.org>
References: <200606082109.34338.gerrit@erg.abdn.ac.uk>
	<20060608.151347.55505744.davem@davemloft.net>
	<200606091036.42075.gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jmorris@namei.org, alan@lxorguk.ukuu.org.uk,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, kaber@coreworks.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:41746 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S965257AbWFIN2h
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 09:28:37 -0400
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200606091036.42075.gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <200606091036.42075.gerrit@erg.abdn.ac.uk> (at Fri, 9 Jun 2006 10:36:41 +0100), Gerrit Renker <gerrit@erg.abdn.ac.uk> says:

> Thank you for your replies and comments, I will be back when the v6 side is ready.

Please fix the following as well.

1. Put your code in net/ipv4, probably as udplite.c, and remove net/udp-lite/.
   Similarly, plasse put implementation as net/ipv6/udplite.c.
2. Eliminate any cosmetic changes (space, new-line, coding style etc.);
   minimize diffs between udp.c udplite.c

BTW, I cannot find descriptions about fragmentation of 
UDP-Lite in the spec.  Is it yours?

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
