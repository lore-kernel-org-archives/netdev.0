From: Dave Jones <davej@redhat.com>
Subject: broken nat on linus' latest tree.
Date: Wed, 25 Jul 2012 13:44:33 -0400
Message-ID: <20120725174433.GA4462@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52228 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751219Ab2GYRoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2012 13:44:37 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q6PHiavf004534
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 25 Jul 2012 13:44:37 -0400
Received: from gelk.kernelslacker.org (ovpn-112-42.phx2.redhat.com [10.3.112.42])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q6PHiYUK026363
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 25 Jul 2012 13:44:36 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.5) with ESMTP id q6PHiXKG005670
	for <netdev@vger.kernel.org>; Wed, 25 Jul 2012 13:44:33 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id q6PHiXfB005668
	for netdev@vger.kernel.org; Wed, 25 Jul 2012 13:44:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I put Linus' latest tree on my firewall, and found that none 
of the machines in my house can talk to the net any more.

The setup is pretty basic.  eth0 talks to the cable modem,
eth1 talks to lan. ip masq between them.

Running tcpdump, when I run a ping from another machine to the internet,
I see icmp requests arriving on eth1.
I see those requests and their replies going in/out of eth0, but I don't
see the replies being forwarded back to eth1.

(It happens with all traffic, not just icmp).

3.5 works, this is a post-merge regression.

Any ideas ?

	Dave
