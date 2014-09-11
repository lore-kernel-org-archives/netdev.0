From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Blogpost: Explaining why I do PPS measurement with 64 bytes
Date: Thu, 11 Sep 2014 11:18:07 +0200
Message-ID: <20140911111807.754b7336@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38269 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753131AbaIKJSK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2014 05:18:10 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8B9I9Z8031048
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 05:18:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


People generally seem to have a hardtime understanding why I'm using
64byte packets and measuring PPS, when tuning the network stack.
People keep telling me this is artificial benchmarking, which is true,
but there is another reason behind these measurements.

Which I have described in this blogpost:
 http://netoptimizer.blogspot.dk/2014/09/packet-per-sec-measurements-for.html

I'm basically leveraging the PPS measurements to deduct the nanosec
improvements I'm making to the code.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
