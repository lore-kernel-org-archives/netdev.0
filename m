From: Cong Wang <amwang@redhat.com>
Subject: A performance regression of gretap
Date: Wed, 10 Jul 2013 06:01:43 -0400 (EDT)
Message-ID: <327738182.1491147.1373450503005.JavaMail.root@redhat.com>
References: <1025834928.1488534.1373450176613.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:53666 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754022Ab3GJKBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 06:01:45 -0400
In-Reply-To: <1025834928.1488534.1373450176613.JavaMail.root@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Pravin

I just noticed the performance over gretap is very bad,
which is probably caused by your GRE refactor patches.

See below:

# netperf -4 -H 192.168.2.1
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.2.1 () port 0 AF_INET
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    14.01       0.02   

Could you please take a look? And, gre tunnel is fine, this
problem only exists for gretap. I reviewed the gretap code,
but can't find any bug.

It is very easy to reproduce, just setup a gretap device
on both ends, and run netperf over it.

Thanks!
