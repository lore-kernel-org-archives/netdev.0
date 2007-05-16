From: Daniel Schaffrath <daniel.schaffrath@mac.com>
Subject: Purpose of bit shifts in tcp_get_info
Date: Wed, 16 May 2007 15:26:53 +0200
Message-ID: <21FCA9FF-08FB-4C6F-B2C5-669E36A7748C@mac.com>
Mime-Version: 1.0 (Apple Message framework v752.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout.mac.com ([17.250.248.171]:55370 "EHLO smtpout.mac.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753188AbXEPNoP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 09:44:15 -0400
Received: from mac.com (smtpin08-en2 [10.13.10.153])
	by smtpout.mac.com (Xserve/smtpout01/MantshX 4.0) with ESMTP id l4GDR2ns011135
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 06:27:02 -0700 (PDT)
Received: from [192.168.178.24] (p57a4a480.dip0.t-ipconnect.de [87.164.164.128])
	(authenticated bits=0)
	by mac.com (Xserve/smtpin08/MantshX 4.0) with ESMTP id l4GDQwJG001777
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 06:27:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Community,

I was wondering what the purpose of the bit shifts in tcp_get_info  
right after the jiffies conversion might be. What's the time unit  
after that shift?

         info->tcpi_rtt = jiffies_to_usecs(tp->srtt)>>3;
         info->tcpi_rttvar = jiffies_to_usecs(tp->mdev)>>2;
[...]
         info->tcpi_rcv_rtt = jiffies_to_usecs(tp->rcv_rtt_est.rtt)>>3;

Maybe somebody has a hint for me?

Thanks a lot!
Daniel
  
