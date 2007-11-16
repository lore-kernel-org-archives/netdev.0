From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket filter
Date: Fri, 16 Nov 2007 18:02:37 +0100
Message-ID: <m3hcjm6s42.fsf@ursa.amorsen.dk>
References: <473D0482.4050705@cn.fujitsu.com> <20071115.185403.138420969.davem@davemloft.net> <473D0BF8.3060902@cn.fujitsu.com> <20071115.200431.102331739.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:42991 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750747AbXKPRDE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 12:03:04 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1It4ai-0006ry-9T
	for netdev@vger.kernel.org; Fri, 16 Nov 2007 17:02:52 +0000
Received: from hd5b9080a.c45-01-12.sta.perspektivbredband.net ([213.185.8.10])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 16 Nov 2007 17:02:52 +0000
Received: from benny+usenet by hd5b9080a.c45-01-12.sta.perspektivbredband.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 16 Nov 2007 17:02:52 +0000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "DM" == David Miller <davem@davemloft.net> writes:

DM> When the user does a recvmsg() or a poll() on the socket, we will
DM> notice the bad checksum then and increment InErrors. We could in
DM> this case correct the InDatagrams counter by decrementing it in
DM> this case.

Does that mean that InDatagrams can decrease? I would expect some
programs to interpret that as counter overflow.


/Benny


