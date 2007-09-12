From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: net/bluetooth/hci_sock.c:352: error: storage size of 'ctv' isn't
 known
Date: Wed, 12 Sep 2007 06:15:20 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0709120612110.476@localhost.localdomain>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1756516192-1189592120=:476"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:49700 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933124AbXILKRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 06:17:21 -0400
Received: from [192.168.1.100] (CPE0018396a01fc-CM001225dbafb6.cpe.net.cable.rogers.com [72.143.66.27])
	(authenticated bits=0)
	by rubicon.netdirect.ca (8.13.1/8.13.1) with ESMTP id l8CAGweb006220
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 06:17:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1756516192-1189592120=:476
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


  latest git pull, "make allyesconfig" on i386:

  ...
  CC      net/bluetooth/hci_sock.o
net/bluetooth/hci_sock.c: In function ‘hci_sock_cmsg’:
net/bluetooth/hci_sock.c:352: error: storage size of ‘ctv’ isn’t known
net/bluetooth/hci_sock.c:352: warning: unused variable ‘ctv’
make[2]: *** [net/bluetooth/hci_sock.o] Error 1
make[1]: *** [net/bluetooth] Error 2
make: *** [net] Error 2


rday

p.s. dumb question -- what locale should i be using to get those
quotes to not make such a mess of my screen?  thanks.
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://crashcourse.ca
========================================================================
--8323328-1756516192-1189592120=:476--
