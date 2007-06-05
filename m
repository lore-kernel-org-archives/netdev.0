From: Edward Wang <Yujiang.Wang@Sun.COM>
Subject: 2.6.9 packets not received on link-local address
Date: Tue, 05 Jun 2007 15:56:26 +0800
Message-ID: <4665172A.9010400@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sineb-mail-2.sun.com ([192.18.19.7]:40143 "EHLO
	sineb-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763431AbXFEIEx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 04:04:53 -0400
Received: from fe-apac-06.sun.com (fe-apac-06.sun.com [192.18.19.177] (may be forged))
	by sineb-mail-2.sun.com (8.13.6+Sun/8.12.9) with ESMTP id l557vR6s004484
	for <netdev@vger.kernel.org>; Tue, 5 Jun 2007 07:57:28 GMT
Received: from conversion-daemon.mail-apac.sun.com by mail-apac.sun.com
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 id <0JJ500801KNDXP00@mail-apac.sun.com>
 (original mail from Yujiang.Wang@Sun.COM) for netdev@vger.kernel.org; Tue,
 05 Jun 2007 15:57:27 +0800 (SGT)
Received: from [129.158.215.183] by mail-apac.sun.com
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPSA id <0JJ5003J7KRQ1U1G@mail-apac.sun.com> for
 netdev@vger.kernel.org; Tue, 05 Jun 2007 15:57:27 +0800 (SGT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One 2.6.9 machine sends to its own link-local address some packets. But 
it simply can't receive those packets, for both TCP and UDP. If will 
succeeded if:

   - sending to a global address instead of a link-local one;
   - or, machine A sends packets, machine B will receive them;
   - or, 2.6.15 *do* receive TCP packets it sends to its link-local 
address. But UDP still fail.


It seems to be a known issue since 2.6.15 shows some improvement. But I 
can't find anything in mailing list archive. Any pointer?

And, there's a dummy route entry in 2.6.* route table, which use 
loopback_dev as reference device to link-local address. It seems really 
odd. Is it related to the problem I just asked? And why Linux IPv6 stack 
did that?

Thanks in advance.

-Ed
