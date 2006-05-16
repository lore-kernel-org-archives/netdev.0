From: Chris Boot <bootc@bootc.net>
Subject: KERNEL: assertion (!sk->sk_forward_alloc) failed at net/* (again)
Date: Tue, 16 May 2006 11:38:38 +0100
Message-ID: <16537920-30DB-4FF7-BD51-DC8517BF4321@bootc.net>
Mime-Version: 1.0 (Apple Message framework v750)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: grsecurity@grsecurity.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from baldrick.bootc.net ([83.142.228.48]:8892 "EHLO
	baldrick.fusednetworks.co.uk") by vger.kernel.org with ESMTP
	id S1751764AbWEPKik (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 06:38:40 -0400
To: kernel list <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Sorry, no subject last time!

I've just seen the following assertions pop out of one of my servers  
running 2.6.16.9 with grsecurity. I've searched the archives of LKML  
and netdev and I've only found posts relating to 2.6.9, after which  
some related bugs were fixed... It looks like these bugs are related  
to e1000, which is the driver I'm using. The system was running 24  
days before these appeared and it's still running absolutely fine.

May 16 09:15:12 baldrick kernel: [6442250.504000] KERNEL: assertion (! 
sk->sk_forward_alloc) failed at net/core/stream.c (283)
May 16 09:15:12 baldrick kernel: [6442250.513000] KERNEL: assertion (! 
sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (150)

baldrick bootc # ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on

Many thanks,
Chris

PS: I'm not subscribed to netdev.

-- 
Chris Boot
bootc@bootc.net
http://www.bootc.net/

