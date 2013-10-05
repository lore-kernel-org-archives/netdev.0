From: leroy christophe <christophe.leroy@c-s.fr>
Subject: Issue with NFS over NAT since kernel 3.8.x
Date: Sat, 05 Oct 2013 11:32:46 +0200
Message-ID: <524FDCBE.9070407@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-net@vger.kernel.org, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pegase1.c-s.fr ([93.17.236.30]:47306 "EHLO mailhub1.si.c-s.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751408Ab3JEKA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Oct 2013 06:00:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a system with a panel PC running RedHat 7.3, mounting NFS from a 
RedHat 9 NFS Server.

Inbetween, I have a router which is running standard Kernel 3.8.13 and 
provides NAT (Masquerade) to the PC.

Reading the directory and a first file from the PC works well. But when 
trying to read a second file, the router stops forwarding the packets 
from the server back to the masqueraded PC.

It was working well with Kernel 3.7.10
It still fails with Kernel 3.10

Is there any change between 3.7 and 3.8 which could explain it ? How can 
I investigate this problem ?

Christophe
