From: Dave Jones <davej@redhat.com>
Subject: ip_rt_bug questions.
Date: Mon, 18 Apr 2011 17:48:10 -0400
Message-ID: <20110418214809.GA17443@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50540 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751862Ab1DRVsM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 17:48:12 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p3ILmC2w009217
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2011 17:48:12 -0400
Received: from gelk.kernelslacker.org (ovpn-113-155.phx2.redhat.com [10.3.113.155])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p3ILmBhp027628
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2011 17:48:11 -0400
Received: from gelk.kernelslacker.org (gelk [127.0.0.1])
	by gelk.kernelslacker.org (8.14.4/8.14.4) with ESMTP id p3ILmA2s017793
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2011 17:48:10 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.4/8.14.4/Submit) id p3ILmAwk017791
	for netdev@vger.kernel.org; Mon, 18 Apr 2011 17:48:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I managed to trigger this today..

ip_rt_bug: 0.0.0.0 -> 255.255.255.255, ?

if this is useful in some way, maybe it should be enhanced
to print out something else, like a backtrace ?

Also, should it be a printk_ratelimit() ? Or is there
ratelimiting done elsewhere in the routing code ?

or should it just be silenced, leaving just the kfree_skb ?

	Dave

