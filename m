From: Mohan Lal Jangir <mohanlal@samsung.com>
Subject: IPv6 connect: Cannot assign requested address
Date: Wed, 19 Nov 2008 11:12:03 +0530
Message-ID: <44F951F109874751B6BF69C01ABDDC38@samsung4qkw9nm>
Mime-Version: 1.0
Content-Type: text/plain; reply-type=original; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Brian Haley <brian.haley@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:54505 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbYKSFwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 00:52:34 -0500
Received: from epmmp2 (mailout4.samsung.com [203.254.224.34])
 by mailout4.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0KAK000IVFUPYR@mailout4.samsung.com> for
 netdev@vger.kernel.org; Wed, 19 Nov 2008 14:42:26 +0900 (KST)
Received: from samsung4qkw9nm ([107.108.208.34])
 by mmp2.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTPA id <0KAK0007LFUNRX@mmp2.samsung.com> for netdev@vger.kernel.org;
 Wed, 19 Nov 2008 14:42:26 +0900 (KST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a system with following configuration

[localhost:/root] ifconfig eth0
eth0     Link encap:Ethernet  HWaddr 02:00:00:00:01:80
          inet addr:10.10.1.71  Bcast:10.10.1.255  Mask:255.255.255.0
          inet6 addr: fe80::ff:fe00:180/64 Scope:Link

I use a tcp client from this machine to establish connection with a server.
./tcp_client -d 172.16.15.24 -s 10.10.1.71 -p 6789

tcpdump shows following packets
10.10.1.71.33069 > 172.16.15.24.6789: S 3589851089:3589851089(0) win 5840 
<mss 1460,sackOK,timestamp 236863 0,nop,wscale 0> (DF)
10.10.1.71.33069 > 172.16.15.24.6789: S 3589851089:3589851089(0) win 5840 
<mss 1460,sackOK,timestamp 237163 0,nop,wscale 0> (DF)

However if I try with IPv6
./tcp_client -d 2000::86 -s fe80::ff:fe00:180 -p 6789

I get error
connect: Cannot assign requested address

Does it mean it is not possible to even send a SYN packet to a global 
address without having a global address ?

Thanks
-Mohan


