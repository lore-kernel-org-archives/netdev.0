From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 0/2] vxlan, bnx2x offload
Date: Sun, 28 Apr 2013 21:16:00 +0300
Message-ID: <1367172962-17369-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, dmitry@broadcom.com
To: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3502 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755596Ab3D1SQV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Apr 2013 14:16:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Dave,

The series fixes GSO flags in vxlan xmit code and
adds appropriate code for bnx2x driver to utilize
fw support for UDP tunneling protocols offload.

Netperf's results below show improvement in throughput
between two vxlan interfaces:
before:
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 9.0.0.2 (9.0.0.2) port 0 AF_INET
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.20     228.73   

after:
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 9.0.0.2 (9.0.0.2) port 0 AF_INET
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.00    3314.75   


Thanks,
Dmitry
