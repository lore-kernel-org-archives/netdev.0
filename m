From: leroy christophe <christophe.leroy@c-s.fr>
Subject: Huge performance degradation for UDP between kernel 2.4.17 and 2.6.x
Date: Thu, 02 Aug 2012 16:02:28 +0200
Message-ID: <501A8874.9090600@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pegase1.c-s.fr ([93.17.236.30]:40980 "EHLO mailhub1.si.c-s.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752755Ab2HBOaf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2012 10:30:35 -0400
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id ACB6E1C835C
	for <netdev@vger.kernel.org>; Thu,  2 Aug 2012 15:02:26 +0200 (CEST)
Received: from mailhub1.si.c-s.fr ([192.168.12.234])
	by localhost (mailhub1.c-s.fr [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id amP7HV-Td4FD for <netdev@vger.kernel.org>;
	Thu,  2 Aug 2012 15:02:26 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 9392F1C8354
	for <netdev@vger.kernel.org>; Thu,  2 Aug 2012 15:02:26 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 8A29223DC6
	for <netdev@vger.kernel.org>; Thu,  2 Aug 2012 16:02:28 +0200 (CEST)
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id XSXLk3GYiYnM for <netdev@vger.kernel.org>;
	Thu,  2 Aug 2012 16:02:28 +0200 (CEST)
Received: from [127.0.0.1] (unknown [172.25.231.59])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 5E59B23DC3
	for <netdev@vger.kernel.org>; Thu,  2 Aug 2012 16:02:28 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I'm having a big issue with UDP. Using a powerpc board (MPC860).

With our board running kernel 2.4.17, I'm able to send 160000 voice 
packets (UDP, 96 bytes per packet) in 11 seconds.
With the same board running either Kernel 2.6.35.14 or Kernel 3.4.7, I 
need 55 seconds to send the same amount of packets.


Is there anything to tune in order to get same output rate as with 
Kernel 2.4 ?

Regards
Christophe
