From: benzi vizman <benziwa@netvision.net.il>
Subject: schedule() does not work...
Date: Thu, 04 May 2006 17:59:57 +0300
Message-ID: <479a1253997.445a411d@netvision.net.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxout2.netvision.net.il ([194.90.9.21]:27886 "EHLO
	mxout2.netvision.net.il") by vger.kernel.org with ESMTP
	id S1751492AbWEDPAG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 11:00:06 -0400
Received: from netvision.net.il ([192.168.10.8]) by mxout2.netvision.net.il
 (Sun Java System Messaging Server 6.2-4.03 (built Sep 22 2005))
 with ESMTP id <0IYQ005YDXNXZA00@mxout2.netvision.net.il> for
 netdev@vger.kernel.org; Thu, 04 May 2006 17:59:57 +0300 (IDT)
To: netdev@vger.kernel.org
Content-language: he
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I try to run the following code in kernel (which is similar to apm() function) but it does not seem to work...

if (smp_processor_id() != cpu) {
      current->cpus_allowed = (1UL << cpu);
      schedule();
      if (smp_processor_id() != cpu) {
          BUG();
      }
}

Any idea why?


Benzi.

