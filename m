From: Dave Jones <davej@redhat.com>
Subject: pr_debug usage in raw_sendmsg
Date: Tue, 12 Apr 2011 18:31:37 -0400
Message-ID: <20110412223137.GA25528@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36480 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752944Ab1DLWbj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 18:31:39 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p3CMVdqg030222
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 18:31:39 -0400
Received: from gelk.kernelslacker.org (ovpn-113-86.phx2.redhat.com [10.3.113.86])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p3CMVc9h010611
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 18:31:39 -0400
Received: from gelk.kernelslacker.org (gelk [127.0.0.1])
	by gelk.kernelslacker.org (8.14.4/8.14.4) with ESMTP id p3CMVbet025649
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 18:31:37 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.4/8.14.4/Submit) id p3CMVbjp025647
	for netdev@vger.kernel.org; Tue, 12 Apr 2011 18:31:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While working on my system call fuzzer, I keep getting a lot
of spew in dmesg from raw_sendmsg. Particularly..

[ 6442.690780] no dev
[ 6454.257701] msg_flags 0x00000080
[ 8055.873142] msg->msg_flags = 0xd63f35c1

Is there a good reason for keeping -DDEBUG in net/ieee802154/Makefile ?

Those messages don't look particularly helpful given there's no other context.
(the 'no dev' one in particular looks kinda hopeless)

	Dave
